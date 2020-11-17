// SidePanelViewController.swift
// Copyright (c) 2020 Dylan Gattey

import AppKit
import Engine
import EngineUI
import UI

/// All the views that appear in our side panel, within a scrollable stack view
class SidePanelViewController: NSViewController {
    // MARK: - constants

    /// The spacing between subviews
    static let interItemSpacing: CGFloat = 48

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

    /// Adds a new scrollable stack view to the underlying view after configuring it properly
    private func addScrollableStackView() {
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    /// Create a scrollable stack view, adding the config and debug views to it
    override func viewDidLoad() {
        view.translatesAutoresizingMaskIntoConstraints = false
        addScrollableStackView()
    }

    /// Swaps a config view out for an existing old one
    func resetViews<T: ShaderDataProviderProtocol>(with dataProvider: T? = nil) {
        Set(stackView.underlyingStackView.views).subtracting(stickyViews).forEach { removableView in
            removableView.removeFromSuperview()
        }
        // Adds sticky views below config views
        Set(stickyViews).subtracting(stackView.underlyingStackView.views).forEach { viewToAdd in
            stackView.underlyingStackView.addView(viewToAdd, in: .bottom)
        }
        if let configView = dataProvider as? NSView {
            stackView.underlyingStackView.addView(configView, in: .top)
        }
    }
}
