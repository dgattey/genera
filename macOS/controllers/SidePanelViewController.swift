//
//  SidePanelViewController.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import AppKit

/// All the views that appear in our side panel, within a scrollable stack view
class SidePanelViewController: NSViewController {
    
    // MARK: - constants
    
    /// Min width of the view owned here
    private static let minWidth: CGFloat = 380
    
    /// The spacing between subviews
    static let interItemSpacing = LabeledView.HeaderStyle.section.spacing * 1.5
    
    // MARK: - variables
    
    /// Debug view for the whole app, doesn't change
    private lazy var debugView: DebugView = DebugView()
    
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
            right: LabeledView.HeaderStyle.section.spacing)
        return stackView
    }()
    
    /// Debug delegate passthrough
    weak var debugDelegate: DebugDelegate? {
        return debugView
    }
    
    /// MARK: - functions
    
    /// Adds a new scrollable stack view to the underlying view after configuring it properly
    private func addScrollableStackView() {
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.widthAnchor.constraint(greaterThanOrEqualToConstant: SidePanelViewController.minWidth)
        ])
    }
    
    /// Create a scrollable stack view, adding the config and debug views to it
    override func viewDidLoad() {
        view.translatesAutoresizingMaskIntoConstraints = false
        addScrollableStackView()
        stackView.underlyingStackView.addView(debugView, in: .bottom)
    }
    
    /// Swaps a config view out for an existing old one
    func add<NewView: ConfigView, OldView: ConfigView>(configView: NewView,
                                                       removing oldView: OldView) {
        for view in stackView.subviews {
            if view == oldView || view as? OldView != nil {
                view.removeFromSuperview()
            }
        }
        add(configView: configView)
    }
    
    /// Adds a new config view to this side panel
    func add<NewView: ConfigView>(configView: NewView) {
        stackView.underlyingStackView.addView(configView, in: .top)
    }

}
