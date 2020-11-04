//
//  GeneraDebugView.swift
//  Genera
//
//  Created by Dylan Gattey on 11/1/20.
//

import Foundation
import Cocoa

// MARK: - GeneraDebugView

class GeneraDebugView: NSView {
    
    @IBOutlet var visibleChunkBounds: NSTextField!
    @IBOutlet var numGeneratedChunks: NSTextField!
    @IBOutlet var generationQueue: NSTextField!
    @IBOutlet var userPosition: NSTextField!
    @IBOutlet var currentViewport: NSTextField!

    /// Updates any field, safely!
    private static func update(_ field: NSTextField, to value: Any) {
        DispatchQueue.main.async {
            field.stringValue = String(describing: value)
        }
    }
}

// MARK: - DebugDelegate

extension GeneraDebugView: DebugDelegate {
    func didUpdateChunkBounds(to value: ChunkRegion) {
        GeneraDebugView.update(visibleChunkBounds, to: value)
    }
    
    func didUpdateNumGeneratedChunks(to value: Int) {
        GeneraDebugView.update(numGeneratedChunks, to: value)
    }
    
    func didUpdateGenerationQueue(to value: (needsGeneration: Int, inProgress: Int)) {
        GeneraDebugView.update(generationQueue, to: value)
    }
    
    func didUpdateUserPosition(to value: MTLViewport) {
        GeneraDebugView.update(userPosition, to: value)
    }
    
    func didUpdateCurrentViewport(to value: MTLViewport) {
        GeneraDebugView.update(currentViewport, to: value)
    }
    
    
}
