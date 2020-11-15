// ZoomDirection.swift
// Copyright (c) 2020 Dylan Gattey

import Foundation

/// Directions to zoom in
enum ZoomDirection {
    case `in`(_ amount: Double)
    case out(_ amount: Double)

    /// Creates a zoom direction from a scalar amount (negative is into the screen)
    init(_ amount: Double) {
        self = amount < 0 ? .in(abs(amount)) : .out(amount)
    }
}
