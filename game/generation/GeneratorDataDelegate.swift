//
//  GeneratorProtocol.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import Foundation

// A protocol any generator of data must conform to
protocol GeneratorDataDelegate: GeneratorProtocol {
    
    // The size of a chunk (same in both dimensions)
    var chunkSize: Int { get }
    
    // The static size of one chunk's vertices
    var verticesBufferSize: Int { get }
    
    // The static size of one chunk's colors
    var colorsBufferSize: Int { get }
    
    // Gets vertices for a particular chunk
    func vertices(for chunk: Chunk) -> [Float]
    
    // Gets colors for a particular chunk
    func colors(for chunk: Chunk) -> [Float]
    
}
