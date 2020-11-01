//
//  GeneratorProtocol.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import Foundation

// A protocol any generator of data must conform to)
protocol GeneratorProtocol {
    
    /// Starts generating the map itselff
    func startMapGeneration() -> Void
    
    /// Should asynchronously generate a chunk and notify the delegate when done (if needed)
    func generateChunkIfNeeded(_ chunk: Chunk)
    
    /// Ensures these visible chunks plus some internally-configured padding is generated
    func didUpdateVisibleChunks(_ ranges: (x: Range<Int>, y: Range<Int>))
    
}
