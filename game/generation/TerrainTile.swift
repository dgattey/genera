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
    
    /// Size of one tile in pixels
    static var tileSize: Int {
        return 4096
    }
    
    /// Size of one chunk in # of tiles - one chunk only has one tile for terrain for speed
    static var chunkSize: Int {
        return 1
    }
    
    let x: Int
    let y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    /// Returns all vertices for this tile, with positions
    var vertices: [TerrainVertex] {
        return triangles.map { TerrainVertex(position: $0) }
    }

}
