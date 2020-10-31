//
//  BasicGenerator.swift
//  Genera
//
//  Created by Dylan Gattey on 10/29/20.
//

import Metal
import simd

// Just generates a random map
class BasicGenerator: GeneratorProtocol, GeneratorDataDelegate {
    
    // MARK: constants
    
    private static let chunkDimension = 32
    
    // TODO: @dgattey move to renderer
    private static let pixelSizeMultiplier: Float = 24
    
    // MARK: variables
    
    private var chunks: Dictionary<Chunk, [Tile]> = Dictionary()
    weak var mapUpdateDelegate: MapUpdateDelegate?
    
    // MARK: - GeneratorDataDelegate
    
    let chunkSize = BasicGenerator.chunkDimension
    let verticesBufferSize = Tile.verticesBufferSize * BasicGenerator.chunkDimension * BasicGenerator.chunkDimension
    let colorsBufferSize = Tile.colorsBufferSize * BasicGenerator.chunkDimension * BasicGenerator.chunkDimension
    
    // Asynchronously generates a chunk of data and notifies our delegate
    func generateChunk(_ chunk: Chunk) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let tiles = (0 ..< BasicGenerator.chunkDimension).flatMap { x -> [Tile] in
                return (0 ..< BasicGenerator.chunkDimension).map { y -> Tile in
                    let tileX = x + chunk.x * BasicGenerator.chunkDimension
                    let tileY = y + chunk.y * BasicGenerator.chunkDimension
                    let kind = Tile.Kind(rawValue: Int.random(in: (0..<3))) ?? .water
                    return Tile(x: tileX, y: tileY, kind: kind)
                }
            }
            
            strongSelf.chunks[chunk] = tiles
            
            DispatchQueue.main.async {
                strongSelf.mapUpdateDelegate?.didUpdateTiles(in: chunk)
            }
        }
    }
    
    // Returns vertices for a particular chunk of data, or nil
    func vertices(for chunk: Chunk) -> [Float] {
        guard let tiles = chunks[chunk] else {
            return []
        }
        return tiles.flatMap { tile in
            return tile.vertices.map { vertex in
                return vertex * BasicGenerator.pixelSizeMultiplier
            }
        }
    }
    
    // Returns colors for a particular chunk of data, or nil
    func colors(for chunk: Chunk) -> [Float] {
        guard let tiles = chunks[chunk] else {
            return []
        }
        return tiles.flatMap { tile in
            return tile.color.map { colorValue in
                return colorValue
            }
        }
    }
    
}
