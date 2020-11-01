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
