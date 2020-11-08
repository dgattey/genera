//
//  SidePanelViewController.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import AppKit

/// All the views that appear in our side panel, within a scrollable stack view
class SidePanelViewController: NSViewController {
    
    typealias ShaderDataProviderType = TerrainConfigView
    
    // MARK: - constants
    
    /// Min width of the view owned here
    private static let minWidth: CGFloat = 380
    
    /// The spacing between subviews
    static let interItemSpacing = LabeledView.HeaderStyle.section.spacing * 1.5
    
    // MARK: - variables
    
    /// Debug view for the whole app
    private lazy var debugView: DebugView = DebugView()
    
    /// Config view for the terrain generator
    private lazy var terrainConfigView = TerrainConfigView(updateDelegate: updateDelegate)
    
    /// Debug delegate passthrough
    weak var debugDelegate: DebugDelegate? {
        return debugView
    }
    
    /// Shader config data provider passthrough
    weak var shaderConfigDataProvider: ShaderDataProviderType? {
        return terrainConfigView
    }
    
    /// Used in sending updates through
    weak var updateDelegate: ConfigUpdateDelegate? {
        didSet {
            terrainConfigView.updateDelegate = updateDelegate
        }
    }
    
    /// MARK: - functions
    
    /// Adds a new scrollable stack view to the given view after configuring it properly
    private static func addScrollableStackView(to view: NSView) -> ScrollableStackView {
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
        
        // Constrain it to fill the view
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.widthAnchor.constraint(greaterThanOrEqualToConstant: SidePanelViewController.minWidth)
        ])
        return stackView
    }
    
    /// Create a scrollable stack view, adding the config and debug views to it
    override func viewDidLoad() {
        view.translatesAutoresizingMaskIntoConstraints = false
        let stackView = SidePanelViewController.addScrollableStackView(to: view)
        stackView.underlyingStackView.addView(debugView, in: .top)
        stackView.underlyingStackView.addView(terrainConfigView, in: .top)
    }

}
