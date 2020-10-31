//
//  GeneratorProtocol.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import Foundation

// A protocol any generator of data must conform to
protocol GeneratorProtocol {
    
    // The size of a chunk (same in both dimensions)
    var chunkSize: Int { get }
    
    // The static size of one chunk's vertices
    var verticesBufferSize: Int { get }
    
    // The static size of one chunk's colors
    var colorsBufferSize: Int { get }
    
    // A map update delegate to notify with changes
    var mapUpdateDelegate: MapUpdateDelegate? { get set }
    
    // Should asynchronously generate a chunk and notify the delegate when done
    func generateChunk(_ chunk: Chunk)
    
    // Gets vertices for a particular chunk
    func vertices(for chunk: Chunk) -> [Float]
    
    // Gets colors for a particular chunk
    func colors(for chunk: Chunk) -> [Float]
    
}
