//
//  BasicGenerator.swift
//  Genera
//
//  Created by Dylan Gattey on 10/29/20.
//

import Metal
import simd
import Combine

/// Just generates a totally random map
class BasicGenerator: GeneratorDataDelegate {
    
    // MARK: constants
    
    /// The amount by which to pad (in chunk units) the visible chunks to smoothly generate
    private static let visibleChunkPadding = 2
    
    /// The amount of chunks in memory we allow (~ 150 MB total)
    private static let maxChunksInMemory = 64
    
    /// The length of the event loop where we process evictions
    private static let evictionEventLoopLength: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(5)
    
    /// Pads the given chunk range by the visible chunk padding to compute what's "in range" of generation
    private static func paddedChunkRanges(_ ranges: (x: Range<Int>, y: Range<Int>)) -> (x: Range<Int>, y: Range<Int>) {
        let pad = { (range: Range<Int>) -> Range<Int> in
            return (range.startIndex - visibleChunkPadding ..< range.endIndex + visibleChunkPadding)
        }
        return (pad(ranges.x), pad(ranges.y))
    }
    
    // MARK: variables
    
    /// TODO: @dgattey replace with bounded priority queue based on access frequency
    /// Basic dict of chunk -> array of tiles
    private var chunks = Dictionary<Chunk, [Tile]>()
    
    /// Makes sure we only ever have one event loop running for evictions (no sense in
    /// making this happen multiple times)
    private var evictionEventLoop: Cancellable?
    
    /// TODO: @dgattey replace with priority queue based on request frequency
    /// The chunks we need to generate and their state
    private var generationQueue = Dictionary<Chunk,(state: ChunkGenerationState, numRequests: Int) >()
    
    /// Used to update the map itself when generation of a chunk is done
    weak var mapUpdateDelegate: MapUpdateDelegate?
    
    /// Used to find out what's visible
    weak var viewportDataDelegate: ViewportDataDelegate?
    
    /// Makes sure only one thing can access the chunks array at once
    private let chunkAccessSemaphore = DispatchSemaphore(value: 1)
    
    /// Gets all visible chunks and pads it by our constant
    private var paddedVisibleRanges: (x: Range<Int>, y: Range<Int>) {
        guard let ranges = viewportDataDelegate?.visibleChunks else {
            assertionFailure("No visible chunks to use (shouldn't be possible)")
            return ((0..<0), (0..<0))
        }
        return BasicGenerator.paddedChunkRanges(ranges)
    }
    
    // MARK: - GeneratorDataDelegate
    
    /// Returns vertices for a particular chunk of data  if it exists, or nil
    func vertices(for chunk: Chunk) -> [Float] {
        chunkAccessSemaphore.wait()
        guard let tiles = chunks[chunk] else {
            chunkAccessSemaphore.signal()
            return []
        }
        chunkAccessSemaphore.signal()
        let tileWidth = Float(Size.tileWidthInPixels)
        return tiles.flatMap { tile in
            return tile.vertices.map { vertex in
                return vertex * tileWidth
            }
        }
    }
    
    /// Returns colors for a particular chunk of data if it exists, or nil
    func colors(for chunk: Chunk) -> [Float] {
        chunkAccessSemaphore.wait()
        guard let tiles = chunks[chunk] else {
            chunkAccessSemaphore.signal()
            return []
        }
        chunkAccessSemaphore.signal()
        return tiles.flatMap { tile in
            return tile.colors.map { colorValue in
                return colorValue
            }
        }
    }
    
    /// Generates the tiles for a given chunk, then dispatches to the main
    /// thread. MUST be called for speed from a background thread. Makes sure
    /// this generation pass is still valid to start
    private func generateTiles(for chunk: Chunk) {
        guard chunk.isWithin(paddedVisibleRanges) else {
            chunkAccessSemaphore.wait()
            generationQueue.removeValue(forKey: chunk)
            chunkAccessSemaphore.signal()
            return
        }
        
        // Set state, generate, and set state again
        chunkAccessSemaphore.wait()
        generationQueue[chunk] = (.isGenerating, generationQueue[chunk]?.numRequests ?? 0)
        chunkAccessSemaphore.signal()
        let tiles = (0 ..< Size.chunk).flatMap { x -> [Tile] in
            return (0 ..< Size.chunk).map { y -> Tile in
                let tileX = x + chunk.x * Size.chunk
                let tileY = y + chunk.y * Size.chunk
                let randomRawTileKind = Int.random(in: (0 ..< Tile.Kind.total))
                let kind = Tile.Kind(rawValue: randomRawTileKind) ?? .water
                return Tile(x: tileX, y: tileY, kind: kind)
            }
        }
        chunkAccessSemaphore.wait()
        chunks[chunk] = tiles
        generationQueue.removeValue(forKey: chunk)
        chunkAccessSemaphore.signal()
        
        DispatchQueue.main.async { [weak self] in
            self?.mapUpdateDelegate?.didGenerate(chunk: chunk)
        }
    }
    
    /// Evicts chunks from the given ranges, assuming this is called from a background
    /// thread for performance reasons.
    private func evictChunksFromBackgroundThread() {
        chunkAccessSemaphore.wait()
        // Evict each if we still have too many
        let keys = chunks.keys
        var excessChunks = chunks.count - BasicGenerator.maxChunksInMemory
        chunkAccessSemaphore.signal()
        
        for chunk in keys {
            // Once we reach 0, exit
            guard excessChunks > 0 else {
                return
            }
            // Make sure we update the count from the current value in the array, and notify when we remove
            if !chunk.isWithin(paddedVisibleRanges) {
                chunkAccessSemaphore.wait()
                chunks.removeValue(forKey: chunk)
                excessChunks = BasicGenerator.maxChunksInMemory - chunks.count
                chunkAccessSemaphore.signal()
                DispatchQueue.main.async { [weak self] in
                    self?.mapUpdateDelegate?.didDelete(chunk: chunk)
                }
            }
        }
    }
    
    /// If we've reached our chunk limit, this starts the loop of evicting them on a background thread
    private func evictChunksIfNeeded() {
        guard evictionEventLoop == nil else {
            return
        }
        
        chunkAccessSemaphore.wait()
        let excessChunks = chunks.count - BasicGenerator.maxChunksInMemory
        chunkAccessSemaphore.signal()
        guard excessChunks > 0 else {
            evictionEventLoop?.cancel()
            return
        }
        
        // We have too many chunks - let's evict
        evictionEventLoop = DispatchQueue.global(qos: .background).schedule(
            after: DispatchQueue.SchedulerTimeType(.now()),
            interval: BasicGenerator.evictionEventLoopLength,
            evictChunksFromBackgroundThread)
    }
    
}

// MARK: - GenerationDelegate

extension BasicGenerator: GeneratorProtocol {
    
    /// Just generates visible chunks to start with
    func startMapGeneration() {
        guard let ranges = viewportDataDelegate?.visibleChunks else {
            assertionFailure("No chunks visible at start of map generation")
            return
        }
        didUpdateVisibleChunks(ranges)
    }
    
    /// Asynchronously generates a chunk of data and notifies our delegate on
    /// the main thread when done. All generation is async and random.
    func generateChunkIfNeeded(_ chunk: Chunk) {
        // Make sure we're not generating this right now or already have generated
        chunkAccessSemaphore.wait()
        if generationQueue.keys.contains(chunk) || chunks.keys.contains(chunk) {
            generationQueue[chunk]?.numRequests += 1
            chunkAccessSemaphore.signal()
            return
        }
        generationQueue[chunk] = (.needsGeneration, generationQueue[chunk]?.numRequests ?? 0 + 1)
        chunkAccessSemaphore.signal()
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.generateTiles(for: chunk)
        }
    }
    
    /// Makes sure these chunks are currently generated, and evict chunks if they're outside our bounds and we're at the limit
    func didUpdateVisibleChunks(_ ranges: (x: Range<Int>, y: Range<Int>)) {
        let paddedRanges = BasicGenerator.paddedChunkRanges(ranges)
        evictChunksIfNeeded()
        for x in paddedRanges.x {
            for y in paddedRanges.y {
                generateChunkIfNeeded(Chunk(x: x, y: y))
            }
        }
    }
    
}
