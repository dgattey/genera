//
//  Chunk.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import Foundation

/// Represents a single chunk identifier
struct Chunk: Hashable {
    let x: Int
    let y: Int
    
    /// Returns if this chunk is within a given x and y range
    func isWithin(_ ranges: (x: Range<Int>, y: Range<Int>)) -> Bool {
        return ranges.x.contains(x) && ranges.y.contains(y)
    }
}

/// Represents a chunk that has a built-in creation date
struct DatedChunk: Hashable, Comparable {
    let value: Chunk
    let creationDate: TimeInterval
    
    static func < (lhs: DatedChunk, rhs: DatedChunk) -> Bool {
        return lhs.creationDate < rhs.creationDate
    }
    
    init(x: Int, y: Int) {
        let chunk = Chunk(x: x, y: y)
        self.init(chunk)
    }
    
    init(_ chunk: Chunk) {
        self.value = chunk
        self.creationDate = Date.timeIntervalSinceReferenceDate
    }
    
    /// Two dated chunks are equivalent if their chunks are the same (date doesn't matter)
    static func == (lhs: DatedChunk, rhs: DatedChunk) -> Bool {
        return lhs.value == rhs.value
    }
    
    /// Just hash the chunk itself
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

/// Represents a chunk that has a count, used for comparing
struct CountedChunk: Hashable, Comparable {
    let value: Chunk
    let count: Int
    
    static func < (lhs: CountedChunk, rhs: CountedChunk) -> Bool {
        return lhs.count < rhs.count
    }
    
    init(_ chunk: Chunk, count: Int = 0) {
        self.value = chunk
        self.count = count
    }
    
    /// Two dated chunks are equivalent if their chunks are the same (count doesn't matter)
    static func == (lhs: CountedChunk, rhs: CountedChunk) -> Bool {
        return lhs.value == rhs.value
    }
    
    /// Just hash the chunk itself
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
    
    /// Returns a new counted chunk that's been incremented by 1
    func incremented() -> CountedChunk {
        return CountedChunk(value, count: count + 1)
    }
}
