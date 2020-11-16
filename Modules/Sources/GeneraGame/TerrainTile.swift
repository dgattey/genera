// TerrainTile.swift
// Copyright (c) 2020 Dylan Gattey

import DataStructuresSwift
import Engine
import simd

/// A positioned tile that appears on the map for terrain
public struct TerrainTile: ChunkDataProtocol {
    /// Size of one tile in pixels
    public static var tileSize: Int {
        4096
    }

    /// Size of one chunk in # of tiles - one chunk only has one tile for terrain for speed
    public static var chunkSize: Int {
        1
    }

    public let x: Int
    public let y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    /// Returns all vertices for this tile, with positions
    public var vertices: [TerrainVertex] {
        triangles.map { TerrainVertex(position: $0) }
    }
}
