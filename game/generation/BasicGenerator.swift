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
    
}

// MARK: - GenerationDelegate

extension BasicGenerator: GeneratorProtocol {
    
    /// Just generates visible chunks to start with
    func startMapGeneration() {
        guard let (xRange, yRange) = viewportDataDelegate?.visibleChunks else {
            assertionFailure("No chunks visible at start of map generation")
            return
        }
        for x in xRange {
            for y in yRange {
                generateChunk(Chunk(x: x, y: y))
            }
        }
    }
    
    /// Asynchronously generates a chunk of data and notifies our delegate on
    /// the main thread when done. All generation is async and random.
    func generateChunk(_ chunk: Chunk) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let tiles = (0 ..< Size.chunk).flatMap { x -> [Tile] in
                return (0 ..< Size.chunk).map { y -> Tile in
                    let tileX = x + chunk.x * Size.chunk
                    let tileY = y + chunk.y * Size.chunk
                    let randomRawTileKind = Int.random(in: (0 ..< Tile.Kind.total))
                    let kind = Tile.Kind(rawValue: randomRawTileKind) ?? .water
                    return Tile(x: tileX, y: tileY, kind: kind)
                }
            }
            
            DispatchQueue.main.async {
                strongSelf.chunks[chunk] = tiles
                strongSelf.mapUpdateDelegate?.didUpdateTiles(in: chunk)
            }
        }
    }
    
    /// Makes sure these chunks are generated!
    func didUpdateVisibleChunks(_ ranges: (x: Range<Int>, y: Range<Int>)) {
        for x in ranges.x {
            for y in ranges.y {
                // TODO: @dgattey this is really slow and breaks something? - I need to sync GPU and CPU better
                // TODO: @dgattey use a threadsafe queue for generation, instead of queueing like this. Because,
                // if the same chunk gets asked for again (resized to the same viewport), it'll get generated twice
                let chunk = Chunk(x: x, y: y)
                if !chunks.keys.contains(chunk) {
                    generateChunk(chunk)
                }
            }
        }
    }
    
}
