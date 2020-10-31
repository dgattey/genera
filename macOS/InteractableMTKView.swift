//
//  InteractableMTKView.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import MetalKit
import Cocoa
import Combine

/// A subclass of MTKView that handles key presses + mouse movements to update the viewport
class InteractableMTKView: MTKView, GeneraMTLView {
    
    // MARK: - constants
    
    /// The length of the event loop where we process key presses/mouse movement
    private static let eventLoopLength: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(20)
    
    /// Converts an event into a direction
    private static func direction(from event: NSEvent) -> Direction? {
        return Direction(from: event.keyCode)
    }
    
    // MARK: - variables
    
    weak var viewportDelegate: ViewportChangeDelegate?
    private var currentDirections = Set<Direction>()
    private var keyPressEventLoop: Cancellable?
    
    /// Makes sure we can zooms and key presses
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    // MARK: - initialization
    
    /// Make sure that as soon as this view appears, it grabs first responder status
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        becomeFirstResponder()
    }
    
    // MARK: - handle events
    
    /// If the key is a direction, add it to our array and start panning in that direction
    override func keyDown(with event: NSEvent) {
        guard let direction = InteractableMTKView.direction(from: event) else {
            super.keyDown(with: event)
            return
        }
        
        // Insert the direction, and start the event loop for panning if needed
        currentDirections.insert(direction)
        if keyPressEventLoop == nil {
            keyPressEventLoop = DispatchQueue.main.schedule(
                after: DispatchQueue.SchedulerTimeType(.now()),
                interval: InteractableMTKView.eventLoopLength,
                panView)
        }
    }
    
    /// If the key is a direction, remove it from our array and stop panning in that direction
    override func keyUp(with event: NSEvent) {
        guard let direction = InteractableMTKView.direction(from: event) else {
            super.keyUp(with: event)
            return
        }
        
        // Remove the direction and stop the event loop if it's empty
        currentDirections.remove(direction)
        if currentDirections.isEmpty {
            keyPressEventLoop?.cancel()
            keyPressEventLoop = nil
        }
    }
    
    // MARK: - helpers
    
    /// Translate the currently keyed directions into functional directions, meaning
    /// that if both north and south are held, they cancel out and don't pan
    private func panView() {
        let nonCancellableDirections = currentDirections.nonCancellable
        if !nonCancellableDirections.isEmpty {
            viewportDelegate?.panViewport(Array(nonCancellableDirections))
        }
    }
    
}
