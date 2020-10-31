//
//  RenderNotifierDelegate.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import Metal

// Notifies when changes are made that the renderer should be aware of
protocol RenderNotifierDelegate: NSObject {
    
    // Update a region of the viewport
    func didUpdateViewport(to viewport: MTLViewport) -> Void
    
}
