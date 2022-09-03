// HideableTitlebarView.swift
// Copyright (c) 2022 Dylan Gattey

import AppKit
import Combine

/// A view for a hideable/showable toolbar/titlebar background
class HideableTitlebarView: NSView {
    // MARK: - variables

    /// Keeps track of sidebar state - can be sent to from a parent
    let isSidebarCollapsed = PassthroughSubject<Bool, Never>()

    /// Subscriber on the subject for isSidebarCollapsed
    private var titlebarHiderCancellable: AnyCancellable?

    // MARK: - colors and layers

    /// Use this to update the color of the titlebar background layer in case we swap dark mode and these catalog colors change
    override func updateLayer() {
        updateColors()
    }

    /// Makes sure our titlebar view is properly added & set up
    override public func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        wantsLayer = true
        alphaValue = 0.0
        sizeToFit()
        if superview == nil {
            titlebarHiderCancellable?.cancel()
        } else {
            titlebarHiderCancellable = isSidebarCollapsed.sink(receiveValue: { [weak self] isCollapsed in
                self?.animator().alphaValue = isCollapsed ? 1.0 : 0.0
            })
        }
    }

    /// Uses the current effective appearance to update the view's background color and stroke
    private func updateColors() {
        guard let layer = layer else {
            assertionFailure("Not set up correctly")
            return
        }
        effectiveAppearance.performAsCurrentDrawingAppearance {
            layer.backgroundColor = NSColor.windowBackgroundColor.cgColor
            layer.borderColor = NSColor(catalogName: "System", colorName: "thinSplitViewDividerColor")?.cgColor
            layer.borderWidth = 1.0
            layer.shadowColor = NSColor.labelColor.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 1.5)
            layer.shadowOpacity = 0.25
            layer.shadowRadius = 2.0
            layer.masksToBounds = false
        }
    }

    // MARK: - sizing

    /// Ensures our titlebar view is sized right, since we're not using constraints
    override func resize(withOldSuperviewSize size: NSSize) {
        super.resize(withOldSuperviewSize: size)
        sizeToFit()
    }

    /// Calculates and sets the frame that fits within the content layout rect for this view
    private func sizeToFit() {
        guard let layoutRect = window?.contentLayoutRect,
              let contentFrame = window?.contentView?.frame
        else {
            return
        }
        let intersectionRect = contentFrame.intersection(layoutRect)
        frame = CGRect(x: contentFrame.minX,
                       y: intersectionRect.origin.y + intersectionRect.size.height,
                       width: contentFrame.size.width,
                       height: contentFrame.size.height - intersectionRect.size.height)
    }
}
