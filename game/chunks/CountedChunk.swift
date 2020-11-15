//
//  DatedChunk.swift
//  Genera
//
//  Created by Dylan Gattey on 11/3/20.
//

import Foundation

/// Represents a chunk that has a count, used for comparing
struct CountedChunk: Hashable, Comparable {
    /// The inner value of the chunk
    let value: Chunk

    /// Current count of the chunk
    let count: Int

    init(_ chunk: Chunk, count: Int = 0) {
        value = chunk
        self.count = count
    }

    /// Use only the creation date in determining less or greater than
    static func < (lhs: CountedChunk, rhs: CountedChunk) -> Bool {
        lhs.count < rhs.count
    }

    /// Two dated chunks are equivalent if their chunks are the same (count doesn't matter)
    static func == (lhs: CountedChunk, rhs: CountedChunk) -> Bool {
        lhs.value == rhs.value
    }

    /// Just hash the chunk itself, not the count
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }

    /// Returns a new counted chunk that's been incremented by 1
    func incremented() -> CountedChunk {
        CountedChunk(value, count: count + 1)
    }
}
