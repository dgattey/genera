//
//  BasicGenerator.swift
//  Genera
//
//  Created by Dylan Gattey on 10/29/20.
//

import Metal
import simd
import Combine
import SwiftPriorityQueue

/// Just generates a totally random map
class BasicGenerator: NSObject, GeneratorDataDelegate {
    
    // MARK: constants
    
    /// The length of the event loop where we process evictions
    private static let evictionEventLoopInterval: DispatchQueue.SchedulerTimeType.Stride = .microseconds(200)
    
    /// Pads the given chunk range by the visible chunk padding to compute what's "in range" of generation
    private static func paddedChunkRanges(_ ranges: (x: Range<Int>, y: Range<Int>)) -> (x: Range<Int>, y: Range<Int>) {
        let pad = { (range: Range<Int>) -> Range<Int> in
            let distance: Int = (range.endIndex - range.startIndex) / 2
            return (range.startIndex - distance ..< range.endIndex + distance)
        }
        return (pad(ranges.x), pad(ranges.y))
    }
    
    // MARK: variables
    
    /// Basic dict of chunk -> array of tiles
    private var chunks = Dictionary<Chunk, [Tile]>()
    
    /// Keeps track of the order we added chunks for smarter removal (pop the top)
    private var recentlyAccessedChunks = PriorityQueue<DatedChunk>(ascending: true)
    
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
    
    /// For debug printing
    weak var debugDelegate: DebugDelegate?
    
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

    /// The amount of chunks in memory we allow (based on viewport size)
    private var maxChunksInMemory: Int {
        return paddedVisibleRanges.x.count * paddedVisibleRanges.y.count
    }
    
    // MARK: - GeneratorDataDelegate
    
    /// Returns vertices for a particular chunk of data if it exists, or nil (and marks it as recently accessed for use in eviction)
    func vertices(for chunk: Chunk) -> [Float] {
        chunkAccessSemaphore.wait()
        unsafelyMarkChunkAsRecentlyAccessed(chunk)
        
        // Get the tiles if they exist
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
    
    // MARK: - helper functions
    
    /// Generates the tiles for a given chunk, then dispatches to the main
    /// thread. MUST be called for speed from a background thread. Makes sure
    /// this generation pass is still valid to start
    private func generateTiles(for chunk: Chunk) {
        guard chunk.isWithin(paddedVisibleRanges) else {
            chunkAccessSemaphore.wait()
            generationQueue.removeValue(forKey: chunk)
            debugDelegate?.didUpdateGenerationQueue(to: generationQueue.count)
            chunkAccessSemaphore.signal()
            return
        }
        
        // Set state, generate, and set state again
        chunkAccessSemaphore.wait()
        generationQueue[chunk] = (.isGenerating, generationQueue[chunk]?.numRequests ?? 0)
        debugDelegate?.didUpdateGenerationQueue(to: generationQueue.count)
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
        
        // Update the chunks array with the tiles and remove from generation queue
        chunkAccessSemaphore.wait()
        chunks[chunk] = tiles
        generationQueue.removeValue(forKey: chunk)
        debugDelegate?.didUpdateGenerationQueue(to: generationQueue.count)
        let totalChunks = chunks.count
        chunkAccessSemaphore.signal()
        
        DispatchQueue.main.async { [weak self] in
            self?.mapUpdateDelegate?.didGenerate(chunk: chunk)
            self?.debugDelegate?.didUpdateNumGeneratedChunks(to: totalChunks)
        }
    }
    
    /// Marks a chunk as recently accessed with semaphore. Use `unsafelyMarkChunkAsRecentlyAccessed` if you're already waiting
    /// on`chunkAccessSemaphore`.
    private func markChunkAsRecentlyAccessed(_ chunk: Chunk) {
        chunkAccessSemaphore.wait()
        unsafelyMarkChunkAsRecentlyAccessed(chunk)
        chunkAccessSemaphore.signal()
    }
    
    /// Marks a chunk as recently accessed. Should be used in a context where you're already waiting on the
    /// `chunkAccessSemaphore`, otherwise it's unsafe. There's an analogous `markChunkAsRecentlyAccessed` if
    /// you need the locking done for you.
    private func unsafelyMarkChunkAsRecentlyAccessed(_ chunk: Chunk) {
        let datedChunk = DatedChunk(chunk)
        // This only works because hashing and equatable use the chunk itself, not the date
        if recentlyAccessedChunks.peek() == datedChunk {
            // Perf improvement if it was the first element
            _ = recentlyAccessedChunks.pop()
        } else if recentlyAccessedChunks.contains(datedChunk) {
            recentlyAccessedChunks.remove(datedChunk)
            Logger.log("+++ replacing \(datedChunk)")
        }
        // Replace whatever was there with newly-dated data
        recentlyAccessedChunks.push(datedChunk)
    }
    
    /// Evicts one chunk at a time, assuming this is called on a loop from a background
    /// thread for performance reasons. Cancels the loop if we have nothing new to evict.
    private func evictOldestChunk() {
        chunkAccessSemaphore.wait()
        let leastRecentChunk = recentlyAccessedChunks.peek()
        let excessChunks = chunks.count - maxChunksInMemory
        
        // Cancel the runner of this function for perf if there's nothing to evict
        guard excessChunks > 0, let evictableChunk = leastRecentChunk else {
            Logger.log("~Evict~ finished evicting: \(excessChunks)")
            chunkAccessSemaphore.signal()
            evictionEventLoop?.cancel()
            evictionEventLoop = nil
            return
        }
        
        // If it's within the visible range, mark as accessed recently (and the element will move
        // so the next iteration of this eviction loop should get a different element)
        guard !evictableChunk.value.isWithin(paddedVisibleRanges) else {
            Logger.log("~Evict~ in viewport (total \(excessChunks) and \(recentlyAccessedChunks.count)) \(evictableChunk)")
            unsafelyMarkChunkAsRecentlyAccessed(evictableChunk.value)
            chunkAccessSemaphore.signal()
            return
        }
        
        // Evict the chunk itself! Also make sure to pop recently accessed chunk because we
        // peeked before. This will be THE SAME because we haven't released the semaphore
        // and we ALWAYS use the semaphore around access to `recentlyAccessedChunks`.
        let mostRecentChunk = recentlyAccessedChunks.pop()
        if evictableChunk.value != mostRecentChunk?.value {
            assertionFailure("Invariant of recently accessed chunks didn't hold")
        }
        let oldTiles = chunks.removeValue(forKey: evictableChunk.value)
        Logger.log("~Evict~ removed a chunk: \(evictableChunk.value) to leave \(chunks.count) in \(paddedVisibleRanges)")
        debugDelegate?.didUpdateNumGeneratedChunks(to: chunks.count)
        chunkAccessSemaphore.signal()
        
        // Only notify if we actually removed something (as we may have already removed this guy)
        if (oldTiles != nil) {
            DispatchQueue.main.async { [weak self] in
                self?.mapUpdateDelegate?.didDelete(chunk: evictableChunk.value)
            }
        }
        
    }
    
    /// If we've reached our chunk limit, this starts the loop of evicting them on a background thread
    private func evictChunksIfNeeded() {
        guard evictionEventLoop == nil else {
            return
        }
        
        chunkAccessSemaphore.wait()
        let excessChunks = chunks.count - maxChunksInMemory
        chunkAccessSemaphore.signal()
        guard excessChunks > 0 else {
            Logger.log("~Evict~ no excess (\(excessChunks))")
            return
        }
        
        // We have too many chunks - let's evict until we have nothing new to evict
        evictionEventLoop = DispatchQueue.global(qos: .utility).schedule(
            after: DispatchQueue.SchedulerTimeType(.now()),
            interval: BasicGenerator.evictionEventLoopInterval,
            evictOldestChunk)
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
            debugDelegate?.didUpdateGenerationQueue(to: generationQueue.count)
            chunkAccessSemaphore.signal()
            return
        }
        generationQueue[chunk] = (.needsGeneration, generationQueue[chunk]?.numRequests ?? 0 + 1)
        debugDelegate?.didUpdateGenerationQueue(to: generationQueue.count)
        chunkAccessSemaphore.signal()
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.generateTiles(for: chunk)
        }
    }
    
    /// Makes sure these chunks are currently generated, and evict chunks if they're outside our bounds and we're at the limit
    func didUpdateVisibleChunks(_ ranges: (x: Range<Int>, y: Range<Int>)) {
        evictChunksIfNeeded()
        let paddedRanges = BasicGenerator.paddedChunkRanges(ranges)
        for x in paddedRanges.x {
            for y in paddedRanges.y {
                generateChunkIfNeeded(Chunk(x: x, y: y))
            }
        }
        debugDelegate?.didUpdateChunkBounds(to: ranges)
    }
    
}
