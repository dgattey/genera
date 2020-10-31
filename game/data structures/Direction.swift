//
//  Direction.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import Foundation

/// Represents all keycodes we care about in UInt16 size
private enum KeyCode: UInt16 {
    case a = 0
    case s = 1
    case d = 2
    case w = 13
    case leftArrow = 123
    case rightArrow = 124
    case downArrow = 125
    case upArrow = 126
}

/// Directions to pan in, with their key codes attached
enum Direction {
    
    /// This array contains opposing (cancels each other out) directions in the form of tuples
    fileprivate static let opposingDirections = [
        (Direction.north, Direction.south ),
        (Direction.east, Direction.west )
    ]
    
    case north
    case east
    case south
    case west
    
    /// Creates a Direction from an event's key code from a key down/up event, or
    /// nil if the key code doesn't create a valid Direction
    init?(from keyCode: UInt16) {
        switch keyCode {
        case KeyCode.a.rawValue, KeyCode.leftArrow.rawValue:
            self = .west
        case KeyCode.w.rawValue, KeyCode.upArrow.rawValue:
            self = .north
        case KeyCode.d.rawValue, KeyCode.rightArrow.rawValue:
            self = .east
        case KeyCode.s.rawValue, KeyCode.downArrow.rawValue:
            self = .south
        default:
            return nil
        }
    }
    
}

/// Extends the array of directions with some help
extension Set where Element == Direction {

    /// Returns directions that don't cancel each other out
    var nonCancellable: Set<Direction> {
        var directions = Set<Direction>(self)
        for (a, b) in Direction.opposingDirections {
            if directions.contains(a) && directions.contains(b) {
                directions.remove(a)
                directions.remove(b)
            }
        }
        return directions
    }
    
}
