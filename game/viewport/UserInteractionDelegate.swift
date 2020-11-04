//
//  UserInteractionDelegate.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

/// Handles changes to the viewport initiated by the user
protocol UserInteractionDelegate: NSObject {
    
    /// Called in response to panning the viewport in the given vectored directions
    func userDidPanViewport(_ directions: Set<VectoredDirection<Double>>) -> Void
    
    /// Called in response to resizing of the viewport to a new size
    func userDidResizeViewport(to size: CGSize) -> Void
    
    /// Called in response to a zoom of the viewport in a given direction at a point onscreen
    func userDidZoomViewport(_ direction: ZoomDirection, at point: NSPoint) -> Void

}
