//
//  GeneratorProtocol.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import Foundation

/// A protocol any generator of map data must conform to
protocol GeneratorProtocol: NSObject {
    
    /// This should be weakly held - debug delegate for all kinds of updates
    var debugDelegate: DebugDelegate? { get set }
    
    /// This should be weakly held - used to find out what's visible
    var viewportDataDelegate: ViewportDataDelegate? { get set }
    
    /// Starts generating the map itself
    func startMapGeneration() -> Void
    
    /// Should asynchronously generate a chunk and notify the delegate when done (if needed)
    func generateChunkIfNeeded(_ chunk: Chunk)
    
    /// Ensures these visible chunks plus some internally-configured padding is generated
    func didUpdateVisibleChunks(_ ranges: (x: Range<Int>, y: Range<Int>))
    
}
