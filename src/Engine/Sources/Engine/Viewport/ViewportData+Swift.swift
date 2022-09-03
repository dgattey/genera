// ViewportData+Swift.swift
// Copyright (c) 2022 Dylan Gattey

import EngineData
import Foundation
import Metal

/// Allows for convenience initializers for ViewportData
extension ViewportData {
    /// Creates a viewport data with an MTLViewport, and its scale
    init(_ viewport: MTLViewport, scaleFactor: CGSize) {
        self.init(origin: vector_float2(Float(viewport.originX), Float(viewport.originY)),
                  size: vector_float2(Float(viewport.width), Float(viewport.height)),
                  scaleFactor: vector_float2(Float(scaleFactor.width), Float(scaleFactor.height)))
    }

    /// Creates a viewport data with CG constructs
    init(origin: CGPoint, size: CGSize, scaleFactor: CGSize) {
        self.init(origin: vector_float2(Float(origin.x), Float(origin.y)),
                  size: vector_float2(Float(size.width), Float(size.height)),
                  scaleFactor: vector_float2(Float(scaleFactor.width), Float(scaleFactor.height)))
    }
}
