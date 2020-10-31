//
//  Size.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import Foundation

/// A collection of common sizes/configurations used throughout generation, rendering, and data structures
enum Size {
    
    /// The size in bytes of one datum, used in pointer math, etc
    static let datum = MemoryLayout<Float>.size
    
    /// The size of one vertex grouping (x and y only)
    static let vertexGrouping = 2
    
    /// The size of one color grouping (r, g, b, alpha)
    static let colorGrouping = 4
    
    /// The size of one viewport grouping (origin.x, origin.y, width, height)
    static let viewportGrouping = 4
    
    /// The number of vertices in all polygons in one tile (two triangles, 3 vertices each)
    static let verticesPerTile = 6
    
    /// The number of vertices in all polygons in one chunk
    static let verticesPerChunk = Size.verticesPerTile * Size.chunk * Size.chunk
    
    /// The size of one tile, rendered, in pixels
    static let tileWidthInPixels = 24
    
    /// The width or height of a chunk, in number of tiles
    static let chunk = 32
}

/// A collection of buffer sizes for various data structures
enum BufferSize {
    
    /// Size of an array of all vertices making up one tile
    private static let tileVertices = Size.verticesPerTile * Size.datum * Size.vertexGrouping
    
    /// Size of an array of all vertices making up one chunk
    static let chunkVertices = tileVertices * Size.chunk * Size.chunk
    
    /// Size of an array of all colors making up one tile (assuming one per vertex)
    private static let tileColors = Size.verticesPerTile * Size.datum * Size.colorGrouping
    
    /// Size of an array of all colors making up one chunk
    static let chunkColors = tileColors * Size.chunk * Size.chunk
}
