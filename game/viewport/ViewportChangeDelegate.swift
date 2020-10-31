//
//  ViewportChangeDelegate.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import Metal

/// Handles changes that should be made to the viewport
protocol ViewportChangeDelegate: NSObject {
    
    /// Pans viewport in the given vectored directions
    func panViewport(_ directions: Set<VectoredDirection<Double>>) -> Void
    
    /// Resizes viewport to a new size
    func resizeViewport(to size: CGSize) -> Void
    
    /// Zooms the viewport in a given direction at a point onscreen
    func zoomViewport(_ direction: ZoomDirection, at point: NSPoint) -> Void

}
