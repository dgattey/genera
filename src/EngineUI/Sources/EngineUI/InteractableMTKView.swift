// InteractableMTKView.swift
// Copyright (c) 2020 Dylan Gattey

import AppKit
import Combine
import Engine
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

    /// Extra padding to add to the titlebar view to make it appear correctly
    private static let titlebarPadding: CGFloat = 10

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

    /// Keeps track of the tracking area for making changes to the titlebar view's visibility
    private var titlebarTrackingArea: NSTrackingArea?

    /// A dummy view that sits where the titlebar does (frame matches) and gives a little indication that this is the titlebar
    private var titlebarView: NSView = {
        let view = NSView(frame: .zero)
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.5).cgColor
        view.layer?.borderColor = NSColor.windowFrameTextColor.withAlphaComponent(0.3).cgColor
        view.layer?.borderWidth = 1.0
        view.isHidden = true
        return view
    }()

    // MARK: - config

    /// Makes sure our titlebar view is properly added & set up
    override public func viewDidMoveToSuperview() {
        guard titlebarView.superview == nil else {
            return
        }
        if superview == nil {
            titlebarView.removeFromSuperview()
        } else {
            addSubview(titlebarView)
        }
    }

    /// Allows us to keep track (haha) of where the mouse is to check how close it is to the titlebar
    override public func updateTrackingAreas() {
        if titlebarTrackingArea != nil, let trackingArea = titlebarTrackingArea {
            removeTrackingArea(trackingArea)
        }
        let trackingArea = NSTrackingArea(rect: bounds,
                                          options: [.mouseMoved, .mouseEnteredAndExited, .activeAlways],
                                          owner: self,
                                          userInfo: nil)
        addTrackingArea(trackingArea)
        titlebarTrackingArea = trackingArea
    }

    /// Ensures our titlebar view is sized right, since we're not using constraints (padded a bit!)
    override public func resizeSubviews(withOldSize _: NSSize) {
        guard let layoutRect = window?.contentLayoutRect else {
            return
        }
        let intersectionRect = frame.intersection(layoutRect)
        titlebarView.animator().isHidden = true
        titlebarView.frame = CGRect(x: frame.minX - InteractableMTKView.titlebarPadding,
                                    y: intersectionRect.origin.y + intersectionRect.size.height,
                                    width: frame.size.width + 2 * InteractableMTKView.titlebarPadding,
                                    height: frame.size.height - intersectionRect.size.height + InteractableMTKView
                                        .titlebarPadding)
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

    /// When the mouse leaves the view, no more tracking it!
    override public func mouseExited(with _: NSEvent) {
        titlebarView.animator().isHidden = true
    }

    /// See if the mouse is close to the titlebar view to highlight it if so (uses double the height to add a bit of extra space)
    override public func mouseMoved(with event: NSEvent) {
        adjustTitlebar(usingMousePoint: event.locationInWindow)
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

    /// Either hides or shows the titlebar based on the mouse's x value (assumes titlebar spans full width)
    private func adjustTitlebar(usingMousePoint mousePoint: NSPoint) {
        let convertedPoint = convert(mousePoint, to: titlebarView)
        titlebarView.animator().isHidden = convertedPoint.y < 0
    }
}
