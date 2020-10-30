//
//  BasicGenerator.swift
//  Genera
//
//  Created by Dylan Gattey on 10/29/20.
//

import Metal
import simd

// Just generates a random map
class BasicGenerator: GeneratorProtocol {
    private static let pixelSizeMultiplier: Float = 24

    internal let chunkSize = 128
    lazy var verticesBufferSize = Tile.verticesBufferSize * chunkSize * chunkSize
    lazy var colorsBufferSize = Tile.colorsBufferSize * chunkSize * chunkSize
    
    private var chunks: Dictionary<Chunk, [Tile]> = Dictionary()
    weak var delegate: GeneratorChangeDelegate?
    
    // Asynchronously generates a chunk of data and notifies our delegate
    func generateChunk(_ chunk: Chunk) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let tiles = (0 ..< strongSelf.chunkSize).flatMap { x -> [Tile] in
                return (0 ..< strongSelf.chunkSize).flatMap { y -> [Tile] in
                    let kind = Tile.Kind(rawValue: Int.random(in: (0..<3))) ?? .water
                    return [Tile(x: x, y: y, kind: kind)]
                }
            }
            
            strongSelf.chunks[chunk] = tiles
            
            DispatchQueue.main.async {
                strongSelf.delegate?.didUpdateTiles(in: chunk)
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
