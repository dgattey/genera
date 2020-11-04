//
//  TerrainTile.swift
//  Genera
//
//  Created by Dylan Gattey on 10/29/20.
//

import Metal
import simd

/// A positioned tile that appears on the map for terrain
struct TerrainTile: ChunkDataProtocol {
    
    // MARK: - variables
    
    let x: Int
    let y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    /// Returns all vertices for this tile, with positions
    var vertices: [TerrainVertex] {
        return positions.map { TerrainVertex(position: $0) }
    }
    
    /// An array of xy vertices, with which to draw multiple triangles, sized to pixels
    private var positions: [simd_float2] {
        let vector: (Int, Int) -> simd_float2 = { (x, y) in
            return simd_float2(Float(x * Size.tileWidthInPixels), Float(y * Size.tileWidthInPixels))
        }
        let triangle1: [simd_float2] = [
            vector(x, y),
            vector(x + 1, y + 1),
            vector(x + 1, y)
        ]
        let triangle2: [simd_float2] = [
            vector(x, y + 1),
            vector(x + 1, y + 1),
            vector(x, y),
        ]
        return triangle1 + triangle2
    }
}
