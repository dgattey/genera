//
//  Tile.swift
//  Genera
//
//  Created by Dylan Gattey on 10/29/20.
//

import Metal
import simd

private enum Constant {
    static let scalar: Float = 200
}

class Tile {
    
    // Dictates which kind of tile this is
    enum Kind: Int {
        case water = 0
        case sand
        case grass
        
        var color: [Float] {
            switch self {
            case .water:
                return [0, 0.2, 0.8, 1]
            case .sand:
                return [0.8, 0.8, 0.6, 1]
            case .grass:
                return [0, 0.8, 0.1, 1]
            }
        }
    }
    
    static let polygonCount = 2
    static let vertexCount = 3
    
    let x: Float
    let y: Float
    let kind: Kind
    
    init(x: Int, y: Int, kind: Kind = .water) {
        self.x = Float(x) * Constant.scalar
        self.y = Float(y) * Constant.scalar
        self.kind = kind
    }
    
    // Creates an array of vertices with which to draw multiple triangles
    var vertices: [Float] {
        return [
            x, y,
            x + Constant.scalar, y + Constant.scalar,
            x + Constant.scalar, y,
            x, y + Constant.scalar,
            x + Constant.scalar, y + Constant.scalar,
            x, y,
        ]
    }
    
    // Converts the tile type into a color array (for as many polygons and vertices as we have)
    var color: [Float] {
        return (0..<Tile.polygonCount * Tile.vertexCount).flatMap({ _ in
            return kind.color
        })
    }
}
