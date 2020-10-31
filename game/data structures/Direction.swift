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
