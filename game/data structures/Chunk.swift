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
    let chunk: Chunk
    let creationDate: TimeInterval
    
    static func < (lhs: DatedChunk, rhs: DatedChunk) -> Bool {
        return lhs.creationDate < rhs.creationDate
    }
    
    init(x: Int, y: Int) {
        let chunk = Chunk(x: x, y: y)
        self.init(chunk)
    }
    
    init(_ chunk: Chunk) {
        self.chunk = chunk
        self.creationDate = Date.timeIntervalSinceReferenceDate
    }
    
    /// Two dated chunks are equivalent if their chunks are the same (date doesn't matter)
    static func == (lhs: DatedChunk, rhs: DatedChunk) -> Bool {
        return lhs.chunk == rhs.chunk
    }
    
    /// Just hash the chunk itself
    func hash(into hasher: inout Hasher) {
        hasher.combine(chunk)
    }
}
