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
        
        var color: simd_float4 {
            switch self {
            case .water:
                return simd_float4(0, 0.2, 0.8, 1)
            case .sand:
                return simd_float4(0.8, 0.8, 0.6, 1)
            case .grass:
                return simd_float4(0, 0.8, 0.1, 1)
            }
        }
    }
    
    static let polygonCount = 2
    static let vertexCount = 3
    
    let origin: simd_float2
    let kind: Kind
    
    init(x: Int, y: Int, kind: Kind = .water) {
        self.origin = simd_float2(Float(x) * Constant.scalar, Float(y) * Constant.scalar)
        self.kind = kind
    }
    
    // Creates an array of vertices with which to draw multiple triangles
    var vertices: [Float] {
        return [
            origin.x, origin.y,
            origin.x + Constant.scalar, origin.y + Constant.scalar,
            origin.x + Constant.scalar, origin.y,
            origin.x, origin.y + Constant.scalar,
            origin.x + Constant.scalar, origin.y + Constant.scalar,
            origin.x, origin.y,
        ]
    }
    
    // Converts the tile type into a color array (for as many polygons and vertices as we have)
    var color: [Float] {
        return (0..<Tile.polygonCount * Tile.vertexCount).flatMap({ _ in
            return [kind.color.x, kind.color.y, kind.color.z, kind.color.w]
        })
    }
}
