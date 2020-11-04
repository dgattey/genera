//
//  Size.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import Foundation

/// A collection of common sizes/configurations used throughout generation, rendering, and data structures
enum Size {
    
    /// The number of vertices in all polygons in one tile (two triangles, 3 vertices each)
    static let verticesPerTile = 6
    
    /// The number of vertices in all polygons in one chunk
    static let verticesPerChunk = Size.verticesPerTile * Size.chunk * Size.chunk
    
    /// The size of one tile, rendered, in pixels
    static let tileWidthInPixels = 12
    
    /// The width or height of a chunk, in number of tiles
    static let chunk = 64
    
    /// The width or height of a chunk, in pixels
    static let chunkInPixels = tileWidthInPixels * chunk
}
