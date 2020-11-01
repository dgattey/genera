//
//  BasicGenerator.swift
//  Genera
//
//  Created by Dylan Gattey on 10/29/20.
//

import Metal
import simd

/// Just generates a totally random map
class BasicGenerator: GeneratorDataDelegate {
    
    // MARK: constants
    
    /// The amount by which to pad (in chunk units) the visible chunks to smoothly generate
    private static let visibleChunkPadding = 3
    
    // MARK: variables
    
    /// TODO: @dgattey replace with bounded priority queue based on access frequency
    /// Basic dict of chunk -> array of tiles
    private var chunks = Dictionary<Chunk, [Tile]>()
    
    /// TODO: @dgattey replace with priority queue based on request frequency
    /// The chunks we need to generate and their state
    private var generationQueue = Dictionary<Chunk,(state: ChunkGenerationState, numRequests: Int) >()
    
    /// Used to update the map itself when generation of a chunk is done
    weak var mapUpdateDelegate: MapUpdateDelegate?
    
    /// Used to find out what's visible
    weak var viewportDataDelegate: ViewportDataDelegate?
    
    /// Makes sure only one thing can access the chunks array at once
    private let chunkAccessSemaphore = DispatchSemaphore(value: 1)
    
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
    /// thread. MUST be called for speed from a background thread.
    private func generateTiles(for chunk: Chunk) {
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
        generationQueue[chunk] = (.done, 0)
        chunkAccessSemaphore.signal()
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.chunkAccessSemaphore.wait()
            strongSelf.chunks[chunk] = tiles
            strongSelf.generationQueue.removeValue(forKey: chunk)
            strongSelf.chunkAccessSemaphore.signal()
            strongSelf.mapUpdateDelegate?.didUpdateTiles(in: chunk)
        }
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
    
    /// Makes sure these chunks are currently generated
    func didUpdateVisibleChunks(_ ranges: (x: Range<Int>, y: Range<Int>)) {
        let padRange = { (range: Range<Int>) -> Range<Int> in
            return (range.startIndex - BasicGenerator.visibleChunkPadding ..< range.endIndex + BasicGenerator.visibleChunkPadding)
        }
        for x in padRange(ranges.x) {
            for y in padRange(ranges.y) {
                generateChunkIfNeeded(Chunk(x: x, y: y))
            }
        }
    }
    
}
