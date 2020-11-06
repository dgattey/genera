//
//  ViewportCoordinatorDelegate.swift
//  Genera
//
//  Created by Dylan Gattey on 11/4/20.
//

import Foundation
import Metal

/// A delegate for changes that occur in the viewport
protocol ViewportCoordinatorDelegate: NSObject {
    
    /// Called when the user position has changed to a new viewport
    func viewportCoordinator(didUpdateUserPositionTo viewport: MTLViewport) -> Void

    /// Called when the visible region gets updated
    func viewportCoordinator(didUpdateVisibleRegionTo: (x: Range<Int>, y: Range<Int>)) -> Void
}

