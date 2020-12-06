// InteractableMTKView.swift
// Copyright (c) 2020 Dylan Gattey

import AppKit
import Combine
import EngineCore
import MetalKit

/// A subclass of MTKView that handles key presses + mouse movements to update the viewport
public class InteractableMTKView: MTKView, InteractableViewProtocol {
    // MARK: - constants

    /// The length of the event loop where we process key presses/mouse movement
    private static let eventLoopLength: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(5)

    /// How much the mouse has to drag for it to be considered a pan in any direction
    private static let mouseMoveThreshold: CGFloat = 0.25

    /// Scales mouse move values to make them cleaner
    private static let mouseMoveScalar: Double = 0.25

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
        if event.deltaX > InteractableMTKView.mouseMoveThreshold {
            directions.insert(VectoredDirection(.west, magnitude: xMagnitude))
        } else if event.deltaX < -1 * InteractableMTKView.mouseMoveThreshold {
            directions.insert(VectoredDirection(.east, magnitude: xMagnitude))
        }
        if event.deltaY > InteractableMTKView.mouseMoveThreshold {
            directions.insert(VectoredDirection(.north, magnitude: yMagnitude))
        } else if event.deltaY < -1 * InteractableMTKView.mouseMoveThreshold {
            directions.insert(VectoredDirection(.south, magnitude: yMagnitude))
        }
        return directions
    }

    // MARK: - variables

    /// Called in response to user interaction
    public weak var userInteractionDelegate: UserInteractionDelegate?

    /// The directions key presses are currently sending us
    private var keyPressDirections = Set<VectoredDirection<Double>>()

    /// The directions the mouse drag is currently sending us
    private var mouseDirections = Set<VectoredDirection<Double>>()

    /// Runs the processer for pans to notify the viewport
    private var panViewEventLoop: Cancellable?

    // MARK: - config

    /// Makes sure our view is properly colored - it needs to set a layer so we can set the background color
    override public func viewDidMoveToSuperview() {
        wantsLayer = true
        updateColors()
    }

    /// Use this to update the color of the background layer in case we swap dark mode and the color changes
    override public func viewDidChangeEffectiveAppearance() {
        updateColors()
    }

    /// Uses the current effective appearance to update the view's background color
    private func updateColors() {
        effectiveAppearance.performAsCurrentDrawingAppearance {
            layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        }
    }

    // MARK: - handle events

    /// Use the y axis's scrolling delta to zoom the viewport in or out
    override public func scrollWheel(with event: NSEvent) {
        // Trackpad is changed phase, mouse wheel is empty phase
        guard event.phase == .changed || event.phase == [],
              let windowView = window?.contentView
        else {
            return
        }
        let amount = Double(event.scrollingDeltaY)
        let convertedPoint = convert(event.locationInWindow, from: windowView)
        userInteractionDelegate?.userDidZoomViewport(ZoomDirection(amount),
                                                     at: convertedPoint,
                                                     withinSize: bounds.size)
    }

    /// If the key is a direction, add it to our array and start panning in that direction
    override public func keyDown(with event: NSEvent) {
        guard let direction = InteractableMTKView.direction(fromKeyPressEvent: event) else {
            super.keyDown(with: event)
            return
        }

        // Insert the direction, and start the event loop for panning if needed
        keyPressDirections.insert(direction)
        if panViewEventLoop == nil {
            panViewEventLoop = DispatchQueue.main.schedule(after: DispatchQueue.SchedulerTimeType(.now()),
                                                           interval: InteractableMTKView.eventLoopLength,
                                                           panView)
        }
    }

    /// If the key is a direction, remove it from our array and stop panning in that direction
    override public func keyUp(with event: NSEvent) {
        guard let direction = InteractableMTKView.direction(fromKeyPressEvent: event) else {
            super.keyUp(with: event)
            return
        }

        // Remove the direction and stop the event loop if it's empty & no mouse movement
        keyPressDirections.remove(direction)
        if keyPressDirections.isEmpty, mouseDirections.isEmpty {
            panViewEventLoop?.cancel()
            panViewEventLoop = nil
        }
    }

    /// Figure out which direction we're dragging in and pan that way
    override public func mouseDragged(with event: NSEvent) {
        // If the click is outside the effective bounds of this view (outside the content layout rect)
        // then we don't want to allow it to do anything
        guard window?.contentLayoutRect.contains(event.locationInWindow) ?? false else {
            return
        }
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
            panViewEventLoop = DispatchQueue.main.schedule(after: DispatchQueue.SchedulerTimeType(.now()),
                                                           interval: InteractableMTKView.eventLoopLength,
                                                           panView)
        }
    }

    /// Stop the pan event loop if we have no key presses tracked
    override public func mouseUp(with _: NSEvent) {
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
        let nonCancellableDirections = VectoredDirection<Double>.nonCancelledDirections(from: directions)
        if !nonCancellableDirections.isEmpty {
            userInteractionDelegate?.userDidPanViewport(nonCancellableDirections)
        }
    }
}
