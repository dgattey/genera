//
//  VectoredDirection.swift
//  Genera
//
//  Created by Dylan Gattey on 10/31/20.
//

import Foundation

/// A direction with magnitude (float precision)
struct VectoredDirection<T: BinaryFloatingPoint>: Hashable {
    /// This array contains opposing (cancels each other out) directions in the form of tuples
    private static var opposingDirections: [(VectoredDirection<T>, VectoredDirection<T>)] {
        [
            (VectoredDirection<T>(.north), VectoredDirection<T>(.south)),
            (VectoredDirection<T>(.east), VectoredDirection<T>(.west)),
        ]
    }

    /// The direction this vectored direction uses
    let direction: Direction

    // The magnitude of movement in the given direction
    let magnitude: T

    /// Defaults magnitude to 1, and takes its absolute value regardless
    init(_ direction: Direction, magnitude: T = 1.0) {
        self.direction = direction
        self.magnitude = abs(magnitude)
    }

    /// Returns directions that don't cancel each other out
    static func nonCancelledDirections(from set: Set<VectoredDirection<T>>) -> Set<VectoredDirection<T>> {
        var directions = Set<VectoredDirection<T>>(set)
        for (a, b) in opposingDirections {
            if directions.contains(a), directions.contains(b) {
                directions.remove(a)
                directions.remove(b)
            }
        }
        return directions
    }

    /// Two vectored directions are equivalent if their directions are the same (magnitude not important)
    static func == (lhs: VectoredDirection<T>, rhs: VectoredDirection<T>) -> Bool {
        lhs.direction == rhs.direction
    }

    /// Just has the direction, not the magniitude
    func hash(into hasher: inout Hasher) {
        hasher.combine(direction)
    }
}
