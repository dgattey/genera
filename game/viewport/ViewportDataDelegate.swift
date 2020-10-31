//
//  ViewportDataDelegate.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import Metal

/// Returns viewport data to other objects
protocol ViewportDataDelegate: NSObject {
    
    /// The current viewport to render within (should always have origin at 0,0)
    var currentViewport: MTLViewport { get }

}
