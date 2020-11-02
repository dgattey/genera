//
//  MapUpdateDelegate.swift
//  Genera
//
//  Created by Dylan Gattey on 10/29/20.
//

import Foundation
import Metal

/// A delegate for use with all map updates to be notifed of actions
protocol MapUpdateDelegate: NSObject {

    /// Called when a chunk has updated tiles to use
    func didGenerate(chunk: Chunk) -> Void
    
    /// Called when a chunk's tiles should be deleted
    func didDelete(chunk: Chunk) -> Void
    
    /// Called when the user position has changed to a new viewport
    func didUpdateUserPosition(to viewport: MTLViewport) -> Void
    
}
