//
//  BasicGenerator.swift
//  Genera
//
//  Created by Dylan Gattey on 10/29/20.
//

import Metal
import simd

class BasicGenerator {
    
    private static let pixelSizeMultiplier = 48
    private static let chunkSize = 64
    
    let tiles: [Tile]
    
    init() {
        self.tiles = BasicGenerator.generate()
    }
    
    private static func generate() -> [Tile] {
        return (0 ..< chunkSize).flatMap { x -> [Tile] in
            return (0 ..< chunkSize).flatMap { y -> [Tile] in
                let kind = Tile.Kind(rawValue: Int.random(in: (0..<3))) ?? .water
                return [Tile(x: x, y: y, kind: kind)]
            }
        }
    }
    
    lazy var vertices: [simd_float1] = {
        return tiles.flatMap { tile in
            return tile.vertices.map { vertex in
                return simd_float1(vertex * BasicGenerator.pixelSizeMultiplier)
            }
        }
    }()
    
    lazy var verticesBufferSize: Int = {
        return Tile.verticesBufferSize * BasicGenerator.chunkSize * BasicGenerator.chunkSize
    }()
    
    lazy var colors: [simd_float1] = {
        return tiles.flatMap { tile in
            return tile.color.map { colorValue in
                return simd_float1(colorValue)
            }
        }
    }()
    
    lazy var colorsBufferSize: Int = {
        return Tile.colorsBufferSize * BasicGenerator.chunkSize * BasicGenerator.chunkSize
    }()
    
}
