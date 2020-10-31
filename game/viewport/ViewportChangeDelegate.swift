//
//  ViewportChangeDelegate.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import Metal

/// Handles changes that should be made to the viewport
protocol ViewportChangeDelegate: NSObject {
    
    /// Pans viewport in the given directions
    func panViewport(_ directions: [Direction]) -> Void
    
    /// Resizes viewport to a new size
    func resizeViewport(to size: CGSize) -> Void

}
