//
//  ChunkDataProvider.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import Foundation

// A protocol any provider of chunk data must conform to
protocol ChunkDataProvider: NSObject {
    
    /// The type of data stored in the chunk data
    associatedtype ChunkDataType: ChunkDataProtocol

    /// Which shader names to use in generation
    var shaders: (vertex: String, fragment: String) { get }
    
    /// Generates a block of ChunkData to use in some form
    func generateChunkData(for chunk: Chunk) -> [ChunkDataType]
    
}
