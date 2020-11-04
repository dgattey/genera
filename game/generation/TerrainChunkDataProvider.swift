//
//  TerrainChunkDataProvider.swift
//  Genera
//
//  Created by Dylan Gattey on 11/4/20.
//

import Foundation

class TerrainChunkDataProvider: NSObject, ChunkDataProvider {
    
    // MARK: - constants
    
    /// The names of the shaders to use with this generator
    private static let shaderNames = (vertex: "terrainVertexShader", fragment: "terrainFragmentShader")
    
    /// Size of a memory layout stride for the vertex type
    private static let strideBufferSize = MemoryLayout<ChunkDataType.VertexType>.stride
    
    /// Size of an array of all vertices for one chunk
    private static let chunkVerticesBufferSize = Size.verticesPerTile * strideBufferSize * Size.chunk * Size.chunk
    
    // MARK: - ChunkDataProvider

    typealias ChunkDataType = TerrainTile
    
    /// Which shader names to use in generation
    var shaders: (vertex: String, fragment: String) {
        return TerrainChunkDataProvider.shaderNames
    }
    
    /// Size of all vertices in one chunk
    var verticesBufferSize: Int {
        return TerrainChunkDataProvider.chunkVerticesBufferSize
    }
    
    /// Stride of the vertex type we're using
    var stride: Int {
        return TerrainChunkDataProvider.strideBufferSize
    }
    
    /// Do the hard work of generating a chunk of data with random tile types
    func generateChunkData(for chunk: Chunk) -> [ChunkDataType] {
        return [TerrainTile(x: chunk.x * Size.chunk, y: chunk.y * Size.chunk)]
    }
    
}
