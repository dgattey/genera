// ViewportCoordinatorDelegate.swift
// Copyright (c) 2020 Dylan Gattey

import Foundation
import Metal

/// A delegate for changes that occur in the viewport
protocol ViewportCoordinatorDelegate: NSObject {
    /// Called when the user position has changed to a new viewport within a drawable size
    func viewportCoordinator(didUpdateUserPositionTo viewport: MTLViewport, inDrawableSize size: CGSize) -> Void

    /// Called when the visible region gets updated
    func viewportCoordinator(didUpdateVisibleRegionTo: (x: Range<Int>, y: Range<Int>)) -> Void
}
