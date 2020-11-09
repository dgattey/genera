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
    
    /// The controller running the game - should always exist but optional for safety
    private var gameViewController: GameViewController?
    
    /// The controller in charge of the sidebar - should always exist but optional for safety
    private var sidePanelViewController: SidePanelViewController?
    
    /// Sets up whole app, using the next run loop to make sure the window has resized at least once before creating the coordinator
    override func windowDidLoad() {
        super.windowDidLoad()
        guard let contentViewController = window?.contentViewController,
              let gameViewController: GameViewController = firstViewController(in: contentViewController),
              let sidePanelViewController: SidePanelViewController = firstViewController(in: contentViewController) else {
            assertionFailure("Views incorrectly set up")
            return
        }
        self.gameViewController = gameViewController
        self.sidePanelViewController = sidePanelViewController
        gameViewController.debugDelegate = sidePanelViewController.debugDelegate
        gameViewController.gameControllerDelegate = self
        
        DispatchQueue.main.async {
            gameViewController.reset(to: .terrain)
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

// MARK: - GameControllerDelegate

extension GeneraWindowController: GameControllerDelegate {
    
    /// Adds the new config view to the sidebar
    func gameController<T: ShaderDataProvider>(hasNewDataProvider dataProvider: T?) {
        sidePanelViewController?.resetViews(with: dataProvider)
        dataProvider?.updateDelegate = gameViewController
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
