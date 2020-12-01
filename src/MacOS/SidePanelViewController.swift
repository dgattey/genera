// SidePanelViewController.swift
// Copyright (c) 2020 Dylan Gattey

import AppKit
import Debug
import UI

/// All the views that appear in our side panel, within a scrollable stack view
class SidePanelViewController: NSViewController {
    // MARK: - constants

    /// The spacing between subviews
    static let interItemSpacing: CGFloat = 48

    /// Minimum width of the sidebar so our toolbar header shows up fine
    private static let minViewWidth: CGFloat = 300

    // MARK: - variables

    /// Debug view for the whole app, doesn't change
    private lazy var debugView = DebugView()

    /// All the views we don't want to get rid of when swapping providers
    private lazy var stickyViews: [NSView] = [debugView]

    /// Stack view for all views in this view controller
    private lazy var stackView: ScrollableStackView = {
        let stackView = ScrollableStackView(layoutOrientation: .vertical)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.underlyingStackView.orientation = .vertical
        stackView.underlyingStackView.alignment = .leading
        stackView.underlyingStackView.distribution = .fill
        stackView.underlyingStackView.spacing = SidePanelViewController.interItemSpacing
        stackView.underlyingStackView.edgeInsets = NSEdgeInsets(
            top: LabeledView.HeaderStyle.section.spacing,
            left: LabeledView.HeaderStyle.section.spacing,
            bottom: LabeledView.HeaderStyle.section.spacing,
            right: LabeledView.HeaderStyle.section.spacing
        )
        return stackView
    }()

    /// Debug delegate passthrough
    weak var debugDelegate: DebugDelegate? {
        debugView
    }

    // MARK: - functions

    /// Create a scrollable stack view in the main view
    override func viewDidLoad() {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(greaterThanOrEqualToConstant: SidePanelViewController.minViewWidth),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    /// Removes non-sticky views from the stack view, adds missing sticky views, and then adds an
    /// optional config view on top.
    func resetViews(toIncludeConfigView configView: NSView? = nil) {
        Set(stackView.underlyingStackView.views).subtracting(stickyViews).forEach { removableView in
            removableView.removeFromSuperview()
        }
        Set(stickyViews).subtracting(stackView.underlyingStackView.views).forEach { viewToAdd in
            stackView.underlyingStackView.addView(viewToAdd, in: .bottom)
        }
        if let configView = configView {
            stackView.underlyingStackView.addView(configView, in: .top)
        }
    }
}
