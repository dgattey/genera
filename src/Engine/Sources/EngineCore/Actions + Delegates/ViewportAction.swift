// ViewportAction.swift
// Copyright (c) 2020 Dylan Gattey

import Foundation
import Metal

/// All possible actions the viewport coordinator has to respond to
public enum ViewportAction {
    /// Pan the viewport in a set of directions
    case panViewport(directions: Set<VectoredDirection<Double>>)

    /// Resize the viewport in a certain size
    case resizeViewport(to: CGSize)

    /// Zooms the viewport in a direction at a point in a size
    case zoomViewport(direction: ZoomDirection, point: NSPoint, withinSize: CGSize)
}
