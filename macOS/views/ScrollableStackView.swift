//
//  ScrollableStackView.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import AppKit

/// Because Apple makes this hard, creates a scrollable stack view using a custom clip view.
/// Configurable in a certain direction, using the constructor.
class ScrollableStackView: NSView {
    
    // MARK: - constants
    
    /// The default layout direction of the stack view unless specified
    private static let defaultLayoutDirection: NSUserInterfaceLayoutOrientation = .horizontal
    
    // MARK: - types
    
    /// A clip view that's flipped by default so it stacks down/right, not up/left
    class FlippedClipView: NSClipView {

        override var isFlipped: Bool {
            return true
        }

    }
    
    // MARK: - initialization
    
    /// Allows customization of the layout direction (either horizontal or vertical)
    init(layoutOrientation: NSUserInterfaceLayoutOrientation = ScrollableStackView.defaultLayoutDirection) {
        super.init(frame: .zero)
        setup(layoutOrientation: layoutOrientation)
    }
    
    /// Given frame + default layout direction
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup(layoutOrientation: ScrollableStackView.defaultLayoutDirection)
    }
    
    /// Zero frame and default layout direction
    required init?(coder decoder: NSCoder) {
        super.init(frame: .zero)
        setup(layoutOrientation: ScrollableStackView.defaultLayoutDirection)
    }
    
    // MARK: - variables
    
    /// Allows access to configuring the stack view from the parent
    let underlyingStackView = NSStackView()
    
    /// The scroll view we put the stack view into
    private let scrollView = NSScrollView()
    
    /// The main clip view we use as the content view in the scroll view
    private let clipView = FlippedClipView()
    
    // MARK - setup
    
    /// Configures all views with the right settings to look and feel proper, laid out in the right
    /// direction based on layout orientation.
    private func configureViews(with layoutOrientation: NSUserInterfaceLayoutOrientation) {
        clipView.translatesAutoresizingMaskIntoConstraints = false
        clipView.drawsBackground = false
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        scrollView.contentView = clipView
        scrollView.documentView = underlyingStackView
        
        underlyingStackView.translatesAutoresizingMaskIntoConstraints = false
        underlyingStackView.orientation = layoutOrientation
        
        // Fills the scroll view in the opposite direction from layout orientation
        let isVertical = layoutOrientation == .vertical
        underlyingStackView.setHuggingPriority(.defaultLow, for: isVertical ? .horizontal : .vertical)
    }
    
    /// Adds and activates constraints so scroll view + clip view are the same size as this
    /// holder view, and the stack view sits at the top of the clip view and grows
    private func activateConstraints(with layoutOrientation: NSUserInterfaceLayoutOrientation) {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            clipView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            clipView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            clipView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            clipView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
        
        /// The side that grows differs on the orientation
        let topConstraint = underlyingStackView.topAnchor.constraint(equalTo: clipView.topAnchor)
        let leftConstraint = underlyingStackView.leftAnchor.constraint(equalTo: clipView.leftAnchor)
        let rightConstraint = underlyingStackView.rightAnchor.constraint(equalTo: clipView.rightAnchor)
        let bottomConstraint = underlyingStackView.bottomAnchor.constraint(equalTo: clipView.bottomAnchor)
        NSLayoutConstraint.activate(layoutOrientation == .vertical
                                        ? [leftConstraint, topConstraint, rightConstraint]
                                        : [topConstraint, leftConstraint, bottomConstraint])
    }
    
    /// Sets up the view hierarchy so things are nested nicely and constraints set
    private func setup(layoutOrientation: NSUserInterfaceLayoutOrientation) {
        configureViews(with: layoutOrientation)
        addSubview(scrollView)
        activateConstraints(with: layoutOrientation)
    }
}
