// ChunkDataProtocol.swift
// Copyright (c) 2020 Dylan Gattey

import Foundation

/// Represents anything that can be stored as chunk data in a generator data provider
protocol ChunkDataProtocol: Hashable {
    associatedtype VertexType: VertexProtocol

    /// Width or height of one tile in pixels
    static var tileSize: Int { get }

    /// Width or height of one chunk in tiles
    static var chunkSize: Int { get }

    // X location of this chunk data
    var x: Int { get }

    // Y location of this chunk data
    var y: Int { get }

    /// Get the vertices for this chunk of data
    var vertices: [VertexType] { get }
}

/// Provides a default implementation to get the triangles in a chunk data (will always use two triangles)
extension ChunkDataProtocol {
    // This needs to match the number of vertices `triangles` returns!
    private static var verticesPerTile: Int {
        6
    }

    /// The number of vertices in all polygons in one chunk
    static var verticesPerChunk: Int {
        verticesPerTile * chunkSize * chunkSize
    }

    /// Tile width times number of tiles in a chunk is size in pixels
    static var chunkSizeInPixels: Int {
        tileSize * chunkSize
    }

    /// Stride of one vertex in memory
    static var stride: Int {
        MemoryLayout<VertexType>.stride
    }

    /// Size of all vertices in one chunk
    static var verticesBufferSize: Int {
        verticesPerChunk * stride
    }

    /// An array of xy vertices, with which to draw multiple triangles, sized to pixels
    var triangles: [simd_float2] {
        let vector: (Int, Int) -> simd_float2 = { x, y in
            simd_float2(Float(x * Self.tileSize), Float(y * Self.tileSize))
        }
        let triangle1: [simd_float2] = [
            vector(x, y),
            vector(x + 1, y + 1),
            vector(x + 1, y),
        ]
        let triangle2: [simd_float2] = [
            vector(x, y + 1),
            vector(x + 1, y + 1),
            vector(x, y),
        ]
        return triangle1 + triangle2
    }
}
