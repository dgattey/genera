//
//  ViewportDataDelegate.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import Metal

/// Returns viewport data to other objects
protocol ViewportDataDelegate: NSObject {
    
    /// The current viewport to render within (should always have origin at 0,0)
    var currentViewport: MTLViewport { get }
    
    /// A way to get the ranges of visible chunks onscreen x and y
    var visibleChunks: (x: Range<Int>, y: Range<Int>) { get }
    
    /// Returns the absolute distance squared from a chunk to the user position. Squared for
    /// speed because division is slow.
    func distanceToUserPositionSquared(fromChunk chunk: Chunk) -> Float

}
