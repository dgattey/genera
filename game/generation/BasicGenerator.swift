//
//  BasicGenerator.swift
//  Genera
//
//  Created by Dylan Gattey on 10/29/20.
//

import Metal
import simd

/// Just generates a totally random map
class BasicGenerator: GeneratorProtocol, GeneratorDataDelegate {
    
    // MARK: variables
    
    /// Basic dict of chunk -> array of tiles
    private var chunks: Dictionary<Chunk, [Tile]> = Dictionary()
    
    /// Used to update the map itself when generation of a chunk is done
    weak var mapUpdateDelegate: MapUpdateDelegate?
    
    // MARK: - GeneratorDataDelegate
    
    /// Asynchronously generates a chunk of data and notifies our delegate on
    /// the mmain thread when done. All generation is async and random
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

extension BasicGenerator: GenerationDelegate {
    
    /// Just generates a few basic chunks to start with
    func startMapGeneration() {
        /// TODO: @dgattey do this better
        for x in (0..<10) {
            for y in (0..<10) {
                generateChunk(Chunk(x: x, y: y))
            }
        }
        for x in (-10..<0) {
            for y in (-10..<0) {
                generateChunk(Chunk(x: x, y: y))
            }
        }
    }
    
}
