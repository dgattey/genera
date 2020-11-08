//
//  GeneraWindowController.swift
//  Genera
//
//  Created by Dylan Gattey on 11/1/20.
//

import AppKit
import MetalKit

/// Owns the views in the app and starts the game controller after an event loop on app start
class GeneraWindowController: NSWindowController {
    
    /// Sets up whole app, using the next run loop to make sure the window has resized at least once before creating the coordinator
    override func windowDidLoad() {
        super.windowDidLoad()
        guard let contentViewController = window?.contentViewController,
              let gameViewController: GameViewController = firstViewController(in: contentViewController),
              let sidePanelViewController: SidePanelViewController = firstViewController(in: contentViewController) else {
            assertionFailure("Views incorrectly set up")
            return
        }
        
        // TODO: @dgattey fix this up
        gameViewController.debugDelegate = sidePanelViewController.debugDelegate
        let configView = TerrainConfigView()
        configView.updateDelegate = gameViewController
        gameViewController.shaderConfigDataProvider = configView
        sidePanelViewController.add(configView: configView)
        
        DispatchQueue.main.async {
            gameViewController.start()
        }
    }
    
    /// Finds the first view controller of a certain type in the given view controller to get around Storyboards being absolute shit
    func firstViewController<T: NSViewController>(in parentController: NSViewController) -> T? {
        for viewController in parentController.children {
            if let match = viewController as? T {
                return match
            }
            if let subChild: T = firstViewController(in: viewController) {
                return subChild
            }
        }
        
        return nil
    }
    
}

// MARK: - NSToolbarDelegate

extension GeneraWindowController: NSToolbarDelegate {

    /// The identifer for the window's label
    private static let appTitleID = "appTitle"
    
    /// Default items
    private static let defaultToolbarIDs: [NSToolbarItem.Identifier] = [
        NSToolbarItem.Identifier(appTitleID),
        .flexibleSpace,
        .toggleSidebar
    ]
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return GeneraWindowController.defaultToolbarIDs
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return GeneraWindowController.defaultToolbarIDs
    }
    
    func toolbar(_ toolbar: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case NSToolbarItem.Identifier(GeneraWindowController.appTitleID):
            let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
            toolbarItem.view = GeneraWindowController.buildAppLabel()
            return toolbarItem
        default:
            return NSToolbarItem(itemIdentifier: itemIdentifier)
        }
    }
    
    /// Builds a view of labels for the title of the app
    private static func buildAppLabel() -> NSView {
        let view = NSStackView()
        view.distribution = .equalSpacing
        view.alignment = .centerY
        
        let titleView: NSTextField = LabeledView.createLabel(from: "Genera", style: .appBold)
        view.addView(titleView, in: .center)
        
        titleView.heightAnchor.constraint(equalToConstant: LabeledView.HeaderStyle.appBold.font.pointSize * 0.88).isActive = true
        return view
    }
}
