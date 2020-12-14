// Chunk.swift
// Copyright (c) 2020 Dylan Gattey

import Foundation

/// Represents a single chunk identifier
public struct Chunk: Hashable {
    public let x: Int
    public let y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    /// Returns if this chunk is within a given x and y range
    public func isWithin(_ region: ChunkRegion) -> Bool {
        region.x.contains(x) && region.y.contains(y)
    }
}

/// Represents a region of chunks
public typealias ChunkRegion = (x: Range<Int>, y: Range<Int>)
