// CGSize+Swift.swift
// Copyright (c) 2022 Dylan Gattey

import Foundation

/// Allows for arithmetic on the CGSize itself
public extension CGSize {
    /// Adds two sizes together and returns a new size
    static func + (left: CGSize, right: CGSize) -> CGSize {
        CGSize(width: left.width + right.width, height: left.height + right.height)
    }

    /// Adds the second size to the first and returns the first
    static func += (left: inout CGSize, right: CGSize) {
        left = left + right
    }

    /// Subtracts the second from the first and returns a new size
    static func - (left: CGSize, right: CGSize) -> CGSize {
        CGSize(width: left.width - right.width, height: left.height - right.height)
    }

    /// Subtracts the second size to the first and returns the first
    static func -= (left: inout CGSize, right: CGSize) {
        left = left - right
    }

    /// Multiples the second by the first and returns a new size
    static func * (left: CGSize, right: CGSize) -> CGSize {
        CGSize(width: left.width * right.width, height: left.height * right.height)
    }

    /// Multiples the second by the first and returns the first
    static func *= (left: inout CGSize, right: CGSize) {
        left = left * right
    }

    /// Divides the second by the first and returns a new size
    static func / (left: CGSize, right: CGSize) -> CGSize {
        CGSize(width: left.width / right.width, height: left.height / right.height)
    }

    /// Divides the second by the first and returns the first
    static func /= (left: inout CGSize, right: CGSize) {
        left = left / right
    }
}
