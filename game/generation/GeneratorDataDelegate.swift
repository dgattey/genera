//
//  GeneratorDataDelegate.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import Foundation

// A protocol any generator of data must conform to
protocol GeneratorDataDelegate: GeneratorProtocol {
    
    /// Which shader names to use in generation
    var shaders: (vertex: String, fragment: String) { get }
    
    // Gets vertices for a particular chunk
    func vertices(for chunk: Chunk) -> [Float]
    
    // Gets colors for a particular chunk
    func colors(for chunk: Chunk) -> [Float]
    
}
