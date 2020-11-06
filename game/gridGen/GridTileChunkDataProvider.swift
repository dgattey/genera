//
//  GridTileChunkDataProvider.swift
//  Genera
//
//  Created by Dylan Gattey on 11/4/20.
//

import Foundation

/// Generates a random set of tiles of certain "biomes" it chunks
class GridTileChunkDataProvider: NSObject, ChunkDataProvider {
    
    typealias ChunkDataType = GridTile
    
    /// Which shader names to use in generation
    var shaders: (vertex: String, fragment: String) {
        return (vertex: "gridVertexShader", fragment: "gridFragmentShader")
    }
    
    /// Do the hard work of generating a chunk of data with random tile types
    func generateChunkData(for chunk: Chunk) -> [ChunkDataType] {
        return (0 ..< ChunkDataType.chunkSize).flatMap { x -> [ChunkDataType] in
            return (0 ..< ChunkDataType.chunkSize).map { y -> ChunkDataType in
                let tileX = x + chunk.x * ChunkDataType.chunkSize
                let tileY = y + chunk.y * ChunkDataType.chunkSize
                let randomRawTileKind = Int.random(in: (0 ..< BiomeType.total.rawValue))
                let kind = BiomeType(rawValue: randomRawTileKind) ?? .ocean
                return GridTile(x: tileX, y: tileY, kind: kind)
            }
        }
    }
    
}
