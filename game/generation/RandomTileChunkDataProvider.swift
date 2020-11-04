//
//  RandomTileChunkDataProvider.swift
//  Genera
//
//  Created by Dylan Gattey on 11/4/20.
//

import Foundation

class RandomTileChunkDataProvider: NSObject, ChunkDataProvider {
    
    // MARK: - constants
    
    /// The names of the shaders to use with this generator
    private static let shaderNames = (vertex: "gridVertexShader", fragment: "gridFragmentShader")
    
    /// Size of a memory layout stride for the vertex type
    private static let strideBufferSize = MemoryLayout<VertexType>.stride
    
    /// Size of an array of all vertices for one chunk
    private static let chunkVerticesBufferSize = Size.verticesPerTile * strideBufferSize * Size.chunk * Size.chunk
    
    // MARK: - ChunkDataProvider
    
    typealias VertexType = GridVertex
    typealias ChunkDataType = Tile
    
    /// Which shader names to use in generation
    var shaders: (vertex: String, fragment: String) {
        return RandomTileChunkDataProvider.shaderNames
    }
    
    /// Size of all vertices in one chunk
    var verticesBufferSize: Int {
        return RandomTileChunkDataProvider.chunkVerticesBufferSize
    }
    
    /// Stride of the vertex type we're using
    var stride: Int {
        return RandomTileChunkDataProvider.strideBufferSize
    }
    
    /// Do the hard work of generating a chunk of data with random tile types
    func generateChunkData(for chunk: Chunk) -> [ChunkDataType] {
        return (0 ..< Size.chunk).flatMap { x -> [Tile] in
            return (0 ..< Size.chunk).map { y -> Tile in
                let tileX = x + chunk.x * Size.chunk
                let tileY = y + chunk.y * Size.chunk
                let randomRawTileKind = Int.random(in: (0 ..< Tile.Kind.total))
                let kind = Tile.Kind(rawValue: randomRawTileKind) ?? .water
                return Tile(x: tileX, y: tileY, kind: kind)
            }
        }
    }
    
}
