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
    
    weak var viewportChangeDelegate: ViewportChangeDelegate?
    
    // If the key press is a directional one, then pan in that direction
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        guard case event.type = NSEvent.EventType.keyDown,
              let characters = event.characters,
              let viewportChangeDelegate = viewportChangeDelegate else {
            return super.performKeyEquivalent(with: event)
        }
        
        if characters.contains(Direction.north.rawValue) {
            viewportChangeDelegate.pan(in: .north)
        } else if characters.contains(Direction.south.rawValue) {
            viewportChangeDelegate.pan(in: .south)
        }
        
        if characters.contains(Direction.east.rawValue) {
            viewportChangeDelegate.pan(in: .east)
        } else if characters.contains(Direction.west.rawValue) {
            viewportChangeDelegate.pan(in: .west)
        }
        return false
    }
    
}
