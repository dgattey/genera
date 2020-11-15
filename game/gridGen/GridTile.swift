// GridTile.swift
// Copyright (c) 2020 Dylan Gattey

import Metal
import simd

/// A position + type of tile that appears on the map
struct GridTile: ChunkDataProtocol {
    /// Size of one tile in pixels
    static var tileSize: Int {
        12
    }

    /// Size of one chunk in # of tiles
    static var chunkSize: Int {
        64
    }

    let x: Int
    let y: Int
    let color: simd_float4

    init(x: Int, y: Int, kind: BiomeType = .ocean) {
        self.x = x
        self.y = y
        color = Biome.defaultBiomeColors[kind] ?? simd_float4()
    }

    /// Returns all vertices for this tile, with positions and colors!
    var vertices: [GridVertex] {
        triangles.map { GridVertex(position: $0, color: color) }
    }
}
