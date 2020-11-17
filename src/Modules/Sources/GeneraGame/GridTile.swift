// GridTile.swift
// Copyright (c) 2020 Dylan Gattey

import DataStructuresSwift
import Engine
import simd

/// A position + type of tile that appears on the map
public struct GridTile: ChunkDataProtocol {
    /// Size of one tile in pixels
    public static var tileSize: Int {
        12
    }

    /// Size of one chunk in # of tiles
    public static var chunkSize: Int {
        64
    }

    public let x: Int
    public let y: Int
    public let color: simd_float4

    public init(x: Int, y: Int, kind: BiomeType = .ocean) {
        self.x = x
        self.y = y
        color = Biome.defaultBiomeColors[kind] ?? simd_float4()
    }

    /// Returns all vertices for this tile, with positions and colors!
    public var vertices: [GridVertex] {
        triangles.map { GridVertex(position: $0, color: color) }
    }
}
