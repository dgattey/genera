// ZoomDirection.swift
// Copyright (c) 2022 Dylan Gattey

import Foundation

/// Directions to zoom in
public enum ZoomDirection {
    case `in`(_ amount: Double)
    case out(_ amount: Double)

    /// Creates a zoom direction from a scalar amount (negative is into the screen)
    public init(_ amount: Double) {
        self = amount < 0 ? .in(abs(amount)) : .out(amount)
    }
}
