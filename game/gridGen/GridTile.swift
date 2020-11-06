//
//  GridTile.swift
//  Genera
//
//  Created by Dylan Gattey on 10/29/20.
//

import Metal
import simd

/// A position + type of tile that appears on the map
struct GridTile: ChunkDataProtocol {
    
    /// Size of one tile in pixels
    static var tileSize: Int {
        return 12
    }
    
    /// Size of one chunk in # of tiles
    static var chunkSize: Int {
        return 64
    }
    
    let x: Int
    let y: Int
    let color: simd_float4
    
    init(x: Int, y: Int, kind: BiomeType = .ocean) {
        self.x = x
        self.y = y
        self.color = Biome.defaultBiomeColors[kind] ?? simd_float4()
        
    }
    
    /// Returns all vertices for this tile, with positions and colors!
    var vertices: [GridVertex] {
        return triangles.map { GridVertex(position: $0, color: color) }
    }

}
