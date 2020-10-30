//
//  PannableMTKView.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import Cocoa
import MetalKit

// A subclass of MTKView that handles key presses
class PannableMTKView: MTKView {
    
    weak var viewportUpdaterDelegate: ViewportUpdaterDelegate?
    
    // If the key press is a directional one, then pan in that direction
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        guard case event.type = NSEvent.EventType.keyDown,
              let characters = event.characters,
              let viewportChangeDelegate = viewportUpdaterDelegate else {
            return super.performKeyEquivalent(with: event)
        }
        
        if characters.contains(Direction.north.rawValue) {
            viewportChangeDelegate.panViewport(.north)
        } else if characters.contains(Direction.south.rawValue) {
            viewportChangeDelegate.panViewport(.south)
        }
        
        if characters.contains(Direction.east.rawValue) {
            viewportChangeDelegate.panViewport(.east)
        } else if characters.contains(Direction.west.rawValue) {
            viewportChangeDelegate.panViewport(.west)
        }
        return false
    }
    
}
