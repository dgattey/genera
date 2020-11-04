//
//  GeneratorDataDelegate.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import Foundation

// A protocol any generator of data must conform to
protocol GeneratorDataDelegate: GeneratorProtocol {
    
    /// The type of the vertex in the buffer + used for sizing
    associatedtype VertexType: VertexProtocol
    
    /// Which shader names to use in generation
    var shaders: (vertex: String, fragment: String) { get }
    
    /// Total size of the vertex array for one chunk of data (in bytes)
    var verticesBufferSize: Int { get }
    
    /// Memory layout stride for the VertexType - can't be done "reflectively"
    var stride: Int { get }
    
    /// Returns vertex data for a particular chunk in the form of an array
    func vertices(for chunk: Chunk) -> [VertexType]
    
}
