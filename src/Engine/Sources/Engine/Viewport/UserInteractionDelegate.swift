// UserInteractionDelegate.swift
// Copyright (c) 2020 Dylan Gattey

import Foundation

/// Handles changes to the viewport initiated by the user
public protocol UserInteractionDelegate: NSObject {
    /// Called in response to panning the viewport in the given vectored directions
    func userDidPanViewport(_ directions: Set<VectoredDirection<Double>>) -> Void

    /// Called in response to resizing of the viewport to a new size
    func userDidResizeViewport(to size: CGSize) -> Void

    /// Called in response to a zoom of the viewport in a given direction at a point onscreen within a given size
    func userDidZoomViewport(_ direction: ZoomDirection, at point: NSPoint, withinSize size: CGSize) -> Void
}
