//
//  BasicGenerator.swift
//  Genera
//
//  Created by Dylan Gattey on 10/29/20.
//

import Metal
import simd

class BasicGenerator {
    
    private static let bounds = 30
    
    let tiles: [Tile]
    
    init() {
        self.tiles = BasicGenerator.generate()
    }
    
    private static func generate() -> [Tile] {
        return (0 ..< bounds / 2).flatMap { x -> [Tile] in
            return (0 ..< bounds / 2).flatMap { y -> [Tile] in
                let kind = Tile.Kind(rawValue: Int.random(in: (0..<30)) % 3) ?? .water
                return [Tile(x: x, y: y, kind: kind)]
            }
        }
    }
    
    lazy var vertices: [Float] = {
        return tiles.flatMap { tile in
            return tile.vertices
        }
    }()
    
    lazy var colors: [Float] = {
        return tiles.flatMap { tile in
            return tile.color
        }
    }()
    
}
