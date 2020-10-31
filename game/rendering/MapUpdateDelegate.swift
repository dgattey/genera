//
//  MapUpdateDelegate.swift
//  Genera
//
//  Created by Dylan Gattey on 10/29/20.
//

import Foundation
import Metal

// A delegate for use with all map updates to be notifed of actions
protocol MapUpdateDelegate: NSObject {

    // Called when a chunk has updated tiles to use
    func didUpdateTiles(in chunk: Chunk) -> Void
    
    // Called when the viewport has changed to a new viewport
    func didUpdateViewport(to viewport: MTLViewport) -> Void
    
}
