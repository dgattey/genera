// CGPoint+Swift.swift
// Copyright (c) 2020 Dylan Gattey

import Foundation

/// Allows for arithmetic on the CGPoint itself
public extension CGPoint {
    // MARK: - CGPoint & CGPoint

    /// Adds two points together and returns the new point
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x + right.x, y: left.y + right.y)
    }

    /// Adds the second point to the first
    static func += (left: inout CGPoint, right: CGPoint) {
        left = left + right
    }

    /// Subtracts the second from the first and returns the new point
    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x - right.x, y: left.y - right.y)
    }

    /// Subtracts the second from the first
    static func -= (left: inout CGPoint, right: CGPoint) {
        left = left - right
    }

    /// Multiplies two points together and returns the new point
    static func * (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x * right.x, y: left.y * right.y)
    }

    /// Multiplies the second point with the first
    static func *= (left: inout CGPoint, right: CGPoint) {
        left = left * right
    }

    /// Divides the first point by the second and returns the new point
    static func / (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x / right.x, y: left.y / right.y)
    }

    /// Divides the first point by the second
    static func /= (left: inout CGPoint, right: CGPoint) {
        left = left / right
    }

    // MARK: - CGPoint & CGSize

    /// Adds a size and a point together
    static func + (left: CGPoint, right: CGSize) -> CGPoint {
        CGPoint(x: left.x + right.width, y: left.y + right.height)
    }

    /// Adds the size to an existing point
    static func += (left: inout CGPoint, right: CGSize) {
        left = left + right
    }

    /// Returns a point with size subtracted from it
    static func - (left: CGPoint, right: CGSize) -> CGPoint {
        CGPoint(x: left.x - right.width, y: left.y - right.height)
    }

    /// Subtracts the size from the point
    static func -= (left: inout CGPoint, right: CGSize) {
        left = left - right
    }

    /// Returns a point with size multiplied by it
    static func * (left: CGPoint, right: CGSize) -> CGPoint {
        CGPoint(x: left.x * right.width, y: left.y * right.height)
    }

    /// Multiplies the point by a size
    static func *= (left: inout CGPoint, right: CGSize) {
        left = left * right
    }

    /// Returns a point divided by size
    static func / (left: CGPoint, right: CGSize) -> CGPoint {
        CGPoint(x: left.x / right.width, y: left.y / right.height)
    }

    /// Divides the point by size
    static func /= (left: inout CGPoint, right: CGSize) {
        left = left / right
    }
}
