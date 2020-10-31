//
//  GeneratorProtocol.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import Foundation

// A protocol any generator of data must conform to)
protocol GeneratorProtocol {
    
    // Should asynchronously generate a chunk and notify the delegate when done
    func generateChunk(_ chunk: Chunk)
    
}
