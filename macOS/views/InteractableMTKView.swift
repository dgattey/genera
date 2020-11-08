//
//  InteractableMTKView.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import MetalKit
import AppKit
import Combine

/// A subclass of MTKView that handles key presses + mouse movements to update the viewport
class InteractableMTKView: MTKView, InteractableViewProtocol {
    
    // MARK: - constants
    
    /// The length of the event loop where we process key presses/mouse movement
    private static let eventLoopLength: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(5)
    
    /// How much the mouse has to drag for it to be considered a pan in any direction
    private static let mouseMoveThreshold: CGFloat = 1.0
    
    /// Scales mouse move values to make them cleaner
    private static let mouseMoveScalar: Double = 0.15
    
    /// Converts a key press event into a direction using key code
    private static func direction(fromKeyPressEvent event: NSEvent) -> VectoredDirection<Double>? {
        guard let direction = Direction(from: event.keyCode) else {
            return nil
        }
        return VectoredDirection(direction)
    }
    
    /// Converts a mouse drag event into a series of directions using deltas
    private static func directions(fromMouseEvent event: NSEvent) -> Set<VectoredDirection<Double>> {
        var directions = Set<VectoredDirection<Double>>()
        let xMagnitude = Double(event.deltaX) * mouseMoveScalar
        let yMagnitude = Double(event.deltaY) * mouseMoveScalar
        if (event.deltaX > InteractableMTKView.mouseMoveThreshold) {
            directions.insert(VectoredDirection(.west, magnitude: xMagnitude))
        } else if (event.deltaX < -1 * InteractableMTKView.mouseMoveThreshold) {
            directions.insert(VectoredDirection(.east, magnitude: xMagnitude))
        }
        if (event.deltaY > InteractableMTKView.mouseMoveThreshold) {
            directions.insert(VectoredDirection(.north, magnitude: yMagnitude))
        } else if (event.deltaY < -1 * InteractableMTKView.mouseMoveThreshold) {
            directions.insert(VectoredDirection(.south, magnitude: yMagnitude))
        }
        return directions
    }
    
    // MARK: - variables
    
    /// Called in response to user interaction
    weak var userInteractionDelegate: UserInteractionDelegate?
    
    /// The directions key presses are currently sending us
    private var keyPressDirections = Set<VectoredDirection<Double>>()
    
    /// The directions the mouse drag is currently sending us
    private var mouseDirections = Set<VectoredDirection<Double>>()
    
    /// Runs the processer for pans to notify the viewport
    private var panViewEventLoop: Cancellable?
    
    /// Makes sure we can zooms and key presses
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    /// Make sure mouse down doesn't move the window so we can drag around
    override var mouseDownCanMoveWindow: Bool {
        return false
    }
    
    // MARK: - initialization
    
    // MARK: - handle events
    
    /// Use the y axis's scrolling delta to zoom the viewport in or out
    override func scrollWheel(with event: NSEvent) {
        // Trackpad is changed phase, mouse wheel is empty phase
        guard event.phase == .changed || event.phase == [] else {
            return
        }
        let amount = Double(event.scrollingDeltaY)
        userInteractionDelegate?.userDidZoomViewport(ZoomDirection(amount), at: event.locationInWindow)
    }
    
    /// If the key is a direction, add it to our array and start panning in that direction
    override func keyDown(with event: NSEvent) {
        guard let direction = InteractableMTKView.direction(fromKeyPressEvent: event) else {
            super.keyDown(with: event)
            return
        }
        
        // Insert the direction, and start the event loop for panning if needed
        keyPressDirections.insert(direction)
        if panViewEventLoop == nil {
            panViewEventLoop = DispatchQueue.main.schedule(
                after: DispatchQueue.SchedulerTimeType(.now()),
                interval: InteractableMTKView.eventLoopLength,
                panView)
        }
    }
    
    /// If the key is a direction, remove it from our array and stop panning in that direction
    override func keyUp(with event: NSEvent) {
        guard let direction = InteractableMTKView.direction(fromKeyPressEvent: event) else {
            super.keyUp(with: event)
            return
        }
        
        // Remove the direction and stop the event loop if it's empty & no mouse movement
        keyPressDirections.remove(direction)
        if keyPressDirections.isEmpty && mouseDirections.isEmpty {
            panViewEventLoop?.cancel()
            panViewEventLoop = nil
        }
    }
    
    /// Figure out which direction we're dragging in and pan that way
    override func mouseDragged(with event: NSEvent) {
        mouseDirections = InteractableMTKView.directions(fromMouseEvent: event)
        guard !mouseDirections.isEmpty else {
            // We're not panning enough to matter in any direction, so cancel the event loop if no key presses
            if keyPressDirections.isEmpty {
                panViewEventLoop?.cancel()
                panViewEventLoop = nil
            }
            return
        }
        
        // Start the event loop for panning if needed
        if panViewEventLoop == nil {
            panViewEventLoop = DispatchQueue.main.schedule(
                after: DispatchQueue.SchedulerTimeType(.now()),
                interval: InteractableMTKView.eventLoopLength,
                panView)
        }
    }
    
    /// Stop the pan event loop if we have no key presses tracked
    override func mouseUp(with event: NSEvent) {
        mouseDirections.removeAll()
        
        if keyPressDirections.isEmpty {
            panViewEventLoop?.cancel()
            panViewEventLoop = nil
        }
    }
    
    // MARK: - helpers
    
    /// Translate the currently keyed directions into functional directions, meaning
    /// that if both north and south are held, they cancel out and don't pan. Mouse
    /// directions take precedent over key press directions (as they have magnitude)
    private func panView() {
        let directions = mouseDirections.union(keyPressDirections)
        let nonCancellableDirections = (VectoredDirection<Double>).nonCancelledDirections(from: directions)
        if !nonCancellableDirections.isEmpty {
            userInteractionDelegate?.userDidPanViewport(nonCancellableDirections)
        }
    }
    
}
