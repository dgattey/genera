//
//  ViewportDataDelegate.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import Metal

// Returns viewport data to other objects
protocol ViewportDataDelegate: NSObject {
    
    // The current, untranslated viewport
    var untranslatedViewport: MTLViewport { get }
    
}
