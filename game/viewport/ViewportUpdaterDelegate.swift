//
//  ViewportUpdaterDelegate.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import Metal

// Handles changes that should be made to the viewport
protocol ViewportUpdaterDelegate: NSObject {
    
    // Pans in a given direction
    func panViewport(_ direction: Direction) -> Void
    
    // Resizes to a new size
    func resizeViewport(to size: CGSize) -> Void

}
