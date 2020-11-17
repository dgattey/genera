// DatedChunk.swift
// Copyright (c) 2020 Dylan Gattey

import Foundation

/// Represents a chunk that has a built-in creation date
public struct DatedChunk: Hashable, Comparable {
    /// The inner value of the chunk
    public let value: Chunk

    /// The creation date of this chunk
    public let creationDate: TimeInterval

    /// Sets it up with an existing chunk
    public init(_ chunk: Chunk) {
        value = chunk
        creationDate = Date.timeIntervalSinceReferenceDate
    }

    /// Use only the creation date in determining less or greater than
    public static func < (lhs: DatedChunk, rhs: DatedChunk) -> Bool {
        lhs.creationDate < rhs.creationDate
    }

    /// Two dated chunks are equivalent if their chunks are the same (date doesn't matter)
    public static func == (lhs: DatedChunk, rhs: DatedChunk) -> Bool {
        lhs.value == rhs.value
    }

    /// Just hash the chunk itself, not the date
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}
