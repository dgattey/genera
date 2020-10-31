//
//  PannableMTKView.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import MetalKit

// A subclass of MTKView that handles key presses to viewport update
class PannableMTKView: MTKView {
    
    weak var viewportDelegate: ViewportChangeDelegate?
    
    // If the key press is a directional one, then pan in that direction
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        guard case event.type = NSEvent.EventType.keyDown,
              let characters = event.characters,
              let delegate = viewportDelegate else {
            return super.performKeyEquivalent(with: event)
        }
        
        if characters.contains(Direction.north.rawValue) {
            delegate.panViewport(.north)
        } else if characters.contains(Direction.south.rawValue) {
            delegate.panViewport(.south)
        }
        
        if characters.contains(Direction.east.rawValue) {
            delegate.panViewport(.east)
        } else if characters.contains(Direction.west.rawValue) {
            delegate.panViewport(.west)
        }
        return false
    }
    
}
