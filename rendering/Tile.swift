//
//  Tile.swift
//  Genera
//
//  Created by Dylan Gattey on 10/29/20.
//

import Metal
import simd

class Tile {
    
    // Dictates which kind of tile this is
    enum Kind: Int {
        case water = 0
        case sand
        case grass
        
        var color: [simd_float1] {
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
    private static let bufferSize = polygonCount * vertexCount * MemoryLayout<simd_float1>.size
    static let verticesBufferSize = bufferSize * 2
    static let colorsBufferSize = bufferSize * 4
    
    let x: Int
    let y: Int
    let kind: Kind
    
    init(x: Int, y: Int, kind: Kind = .water) {
        self.x = x
        self.y = y
        self.kind = kind
    }
    
    // Creates an array of vertices with which to draw multiple triangles
    lazy var vertices: [Int] = {
        return [
            x, y,
            x + 1, y + 1,
            x + 1, y,
            x, y + 1,
            x + 1, y + 1,
            x, y,
        ]
    }()
    
    // Converts the tile type into a color array (for as many polygons and vertices as we have)
    lazy var color: [simd_float1] = {
        return (0..<Tile.polygonCount * Tile.vertexCount).flatMap({ _ in
            return kind.color
        })
    }()
}
