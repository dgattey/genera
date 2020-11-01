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
    
    // MARK: variables
    
    /// Basic dict of chunk -> array of tiles
    private var chunks: Dictionary<Chunk, [Tile]> = Dictionary()
    
    /// The chunks we need to generate (should be queued on the generation queue)
    private var generationQueueKeys = Set<Chunk>()
    
    /// Used to update the map itself when generation of a chunk is done
    weak var mapUpdateDelegate: MapUpdateDelegate?
    
    /// Used to find out what's visible
    weak var viewportDataDelegate: ViewportDataDelegate?
    
    // MARK: - GeneratorDataDelegate
    
    /// Returns vertices for a particular chunk of data  if it exists, or nil
    func vertices(for chunk: Chunk) -> [Float] {
        guard let tiles = chunks[chunk] else {
            return []
        }
        let tileWidth = Float(Size.tileWidthInPixels)
        return tiles.flatMap { tile in
            return tile.vertices.map { vertex in
                return vertex * tileWidth
            }
        }
    }
    
    /// Returns colors for a particular chunk of data if it exists, or nil
    func colors(for chunk: Chunk) -> [Float] {
        guard let tiles = chunks[chunk] else {
            return []
        }
        return tiles.flatMap { tile in
            return tile.colors.map { colorValue in
                return colorValue
            }
        }
    }
    
    /// Generates the tiles for a given chunk, then dispatches to the main
    /// thread. MUST be called for speed from a background thread.
    private func generateTiles(for chunk: Chunk) {
        let tiles = (0 ..< Size.chunk).flatMap { x -> [Tile] in
            return (0 ..< Size.chunk).map { y -> Tile in
                let tileX = x + chunk.x * Size.chunk
                let tileY = y + chunk.y * Size.chunk
                let randomRawTileKind = Int.random(in: (0 ..< Tile.Kind.total))
                let kind = Tile.Kind(rawValue: randomRawTileKind) ?? .water
                return Tile(x: tileX, y: tileY, kind: kind)
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.chunks[chunk] = tiles
            strongSelf.generationQueueKeys.remove(chunk)
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
        if generationQueueKeys.contains(chunk) || chunks.keys.contains(chunk) {
            return
        }
        generationQueueKeys.insert(chunk)
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.generateTiles(for: chunk)
        }
    }
    
    /// Makes sure these chunks are generated!
    func didUpdateVisibleChunks(_ ranges: (x: Range<Int>, y: Range<Int>)) {
        for x in ranges.x {
            for y in ranges.y {
                // TODO: @dgattey this is really slow and breaks something? - I need to sync GPU and CPU better?
                generateChunkIfNeeded(Chunk(x: x, y: y))
            }
        }
    }
    
}
