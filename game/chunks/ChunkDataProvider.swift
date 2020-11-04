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
    
    /// Total size of the vertex array for one chunk of data (in bytes)
    var verticesBufferSize: Int { get }
    
    /// Memory layout stride for the VertexType - can't be done "reflectively"
    var stride: Int { get }
    
    /// Generates a block of ChunkData to use in some form
    func generateChunkData(for chunk: Chunk) -> [ChunkDataType]
    
}
