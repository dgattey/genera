//
//  TerrainChunkDataProvider.swift
//  Genera
//
//  Created by Dylan Gattey on 11/4/20.
//

import Foundation

/// Provides giant 1-tile chunks for use in generation of terrain
class TerrainChunkDataProvider: NSObject, ChunkDataProviderProtocol {
    /// Which shader names to use in generation
    var shaders: (vertex: String, fragment: String) {
        return (vertex: "terrainVertexShader", fragment: "terrainFragmentShader")
    }

    /// The terrain shader config data
    private(set) var shaderDataProvider: TerrainConfigView? = TerrainConfigView()

    /// Do the hard work of generating a chunk of data with random tile types
    func generateChunkData(for chunk: Chunk) -> [TerrainTile] {
        [TerrainTile(x: chunk.x, y: chunk.y)]
    }
}
