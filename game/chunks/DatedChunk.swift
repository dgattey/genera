// DatedChunk.swift
// Copyright (c) 2020 Dylan Gattey
// Created by Dylan Gattey on 11/3/20.

import Foundation

/// Represents a chunk that has a built-in creation date
struct DatedChunk: Hashable, Comparable {
    /// The inner value of the chunk
    let value: Chunk

    /// The creation date of this chunk
    let creationDate: TimeInterval

    /// Sets it up with an existing chunk
    init(_ chunk: Chunk) {
        value = chunk
        creationDate = Date.timeIntervalSinceReferenceDate
    }

    /// Use only the creation date in determining less or greater than
    static func < (lhs: DatedChunk, rhs: DatedChunk) -> Bool {
        lhs.creationDate < rhs.creationDate
    }

    /// Two dated chunks are equivalent if their chunks are the same (date doesn't matter)
    static func == (lhs: DatedChunk, rhs: DatedChunk) -> Bool {
        lhs.value == rhs.value
    }

    /// Just hash the chunk itself, not the date
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}
