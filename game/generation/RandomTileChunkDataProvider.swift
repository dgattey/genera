//
//  RandomTileChunkDataProvider.swift
//  Genera
//
//  Created by Dylan Gattey on 11/4/20.
//

import Foundation

class RandomTileChunkDataProvider: NSObject, ChunkDataProvider {
    
    typealias ChunkDataType = Tile
    
    /// Which shader names to use in generation
    var shaders: (vertex: String, fragment: String) {
        return (vertex: "gridVertexShader", fragment: "gridFragmentShader")
    }
    
    /// Do the hard work of generating a chunk of data with random tile types
    func generateChunkData(for chunk: Chunk) -> [ChunkDataType] {
        return (0 ..< ChunkDataType.chunkSize).flatMap { x -> [Tile] in
            return (0 ..< ChunkDataType.chunkSize).map { y -> Tile in
                let tileX = x + chunk.x * ChunkDataType.chunkSize
                let tileY = y + chunk.y * ChunkDataType.chunkSize
                let randomRawTileKind = Int.random(in: (0 ..< Tile.Kind.total))
                let kind = Tile.Kind(rawValue: randomRawTileKind) ?? .water
                return Tile(x: tileX, y: tileY, kind: kind)
            }
        }
    }
    
}
