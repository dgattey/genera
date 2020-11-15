// Chunk.swift
// Copyright (c) 2020 Dylan Gattey
// Created by Dylan Gattey on 10/30/20.

import Foundation

/// Represents a single chunk identifier
struct Chunk: Hashable {
    let x: Int
    let y: Int

    /// Returns if this chunk is within a given x and y range
    func isWithin(_ region: ChunkRegion) -> Bool {
        region.x.contains(x) && region.y.contains(y)
    }
}

/// Represents a region of chunks
typealias ChunkRegion = (x: Range<Int>, y: Range<Int>)
