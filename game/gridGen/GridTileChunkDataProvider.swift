// GridTileChunkDataProvider.swift
// Copyright (c) 2020 Dylan Gattey

import Foundation

/// Generates a random set of tiles of certain "biomes" it chunks
class GridTileChunkDataProvider: NSObject, ChunkDataProviderProtocol {
    /// Which shader names to use in generation
    var shaders: (vertex: String, fragment: String) {
        return (vertex: "gridVertexShader", fragment: "gridFragmentShader")
    }

    /// No shader data for this provider
    var shaderDataProvider: EmptyShaderDataProvider? {
        nil
    }

    /// Do the hard work of generating a chunk of data with random tile types
    func generateChunkData(for chunk: Chunk) -> [GridTile] {
        (0 ..< ChunkDataType.chunkSize).flatMap { x in
            (0 ..< ChunkDataType.chunkSize).map { y in
                let tileX = x + chunk.x * ChunkDataType.chunkSize
                let tileY = y + chunk.y * ChunkDataType.chunkSize
                let randomRawTileKind = Int.random(in: 0 ..< BiomeType.total.rawValue)
                let kind = BiomeType(rawValue: randomRawTileKind) ?? .ocean
                return GridTile(x: tileX, y: tileY, kind: kind)
            }
        }
    }
}
