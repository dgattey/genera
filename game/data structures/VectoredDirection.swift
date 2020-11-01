//
//  VectoredDirection.swift
//  Genera
//
//  Created by Dylan Gattey on 10/31/20.
//

import Foundation

/// This array contains opposing (cancels each other out) directions in the form of tuples
private let opposingDirections = [
    (VectoredDirection<Double>(.north), VectoredDirection<Double>(.south) ),
    (VectoredDirection<Double>(.east), VectoredDirection<Double>(.west) )
]

/// A direction with magnitude (float precision)
struct VectoredDirection<T: BinaryFloatingPoint>: Hashable {
    
    /// The direction this vectored direction uses
    let direction: Direction
    
    // The magnitude of movement in the given direction
    let magnitude: T
    
    /// Defaults magnitude to 1, and takes its absolute value regardless
    init(_ direction: Direction, magnitude: T = 1.0) {
        self.direction = direction
        self.magnitude = abs(magnitude)
    }
    
    /// Two vectored directions are equivalent if their directions are the same (magnitude not important)
    static func == (lhs: VectoredDirection<T>, rhs: VectoredDirection<T>) -> Bool {
        return lhs.direction == rhs.direction
    }
    
    /// Just has the direction, not the magniitude
    func hash(into hasher: inout Hasher) {
        hasher.combine(direction)
    }
    
}

/// Extends the array of directions with some help
/// TODO: @dgattey figure out how to do this generically
extension Set where Element == VectoredDirection<Double> {

    /// Returns directions that don't cancel each other out
    var nonCancellable: Set<VectoredDirection<Double>> {
        var directions = Set<VectoredDirection<Double>>(self)
        for (a, b) in opposingDirections {
            if directions.contains(a) && directions.contains(b) {
                directions.remove(a)
                directions.remove(b)
            }
        }
        return directions
    }
    
}
