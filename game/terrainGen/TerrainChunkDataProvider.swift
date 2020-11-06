//
//  TerrainChunkDataProvider.swift
//  Genera
//
//  Created by Dylan Gattey on 11/4/20.
//

import Foundation

/// Provides giant 1-tile chunks for use in generation of terrain
class TerrainChunkDataProvider: NSObject, ChunkDataProvider {

    typealias ChunkDataType = TerrainTile
    
    /// Which shader names to use in generation
    var shaders: (vertex: String, fragment: String) {
        return (vertex: "terrainVertexShader", fragment: "terrainFragmentShader")
    }
    
    /// Do the hard work of generating a chunk of data with random tile types
    func generateChunkData(for chunk: Chunk) -> [ChunkDataType] {
        return [TerrainTile(x: chunk.x, y: chunk.y)]
    }
    
}
