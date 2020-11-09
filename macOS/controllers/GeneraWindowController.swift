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
              let sidePanelViewController: SidePanelViewController = firstViewController(in: contentViewController),
              let startingGameType = GameType(rawValue: GameType.titles.first ?? "") else {
            assertionFailure("Views incorrectly set up")
            return
        }
        self.gameViewController = gameViewController
        self.sidePanelViewController = sidePanelViewController
        gameViewController.debugDelegate = sidePanelViewController.debugDelegate
        gameViewController.gameControllerDelegate = self
        
        DispatchQueue.main.async {
            gameViewController.reset(to: startingGameType)
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
    func gameController<T: ShaderDataProviderProtocol>(hasNewDataProvider dataProvider: T?) {
        sidePanelViewController?.resetViews(with: dataProvider)
        dataProvider?.updateDelegate = gameViewController
    }
    
}

// MARK: - NSToolbarDelegate

extension GeneraWindowController: NSToolbarDelegate {

    /// The identifer for the window's app title label
    private static let toolbarItemAppTitle = "dgattey.appTitle"
    
    /// The identifer for the game typ dropdown
    private static let toolbarItemGameType = "dgattey.gameType"
    
    /// Default items
    private static let defaultToolbarIDs: [NSToolbarItem.Identifier] = [
        NSToolbarItem.Identifier(toolbarItemAppTitle),
        .flexibleSpace,
        NSToolbarItem.Identifier(toolbarItemGameType),
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
        case NSToolbarItem.Identifier(GeneraWindowController.toolbarItemAppTitle):
            let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
            toolbarItem.view = GeneraWindowController.buildAppLabel()
            return toolbarItem
        case NSToolbarItem.Identifier(GeneraWindowController.toolbarItemGameType):
            let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
            toolbarItem.view = buildGameTypeSelector()
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
    
    /// Builds a selector for game mode
    private func buildGameTypeSelector() -> NSView {
        let selector = NSPopUpButton()
        selector.addItems(withTitles: GameType.titles)
        selector.target = self
        selector.action = #selector(GeneraWindowController.didChangeGameType)
        let label = LabeledView.createLabel(from: "Game Type:", style: .field)
        let view = NSStackView()
        view.distribution = .equalSpacing
        view.alignment = .centerY
        view.addView(selector, in: .trailing)
        view.addView(label, in: .leading)
        return view
    }
    
    /// Called in response to changing the game type from the toolbar, and changes the controller's game type
    @objc func didChangeGameType(_ sender: AnyObject) {
        if let popupButton = sender as? NSPopUpButton,
           let menuItem = popupButton.selectedItem,
           let gameType = GameType(rawValue: menuItem.title) {
            gameViewController?.reset(to: gameType)
        }
    }
}
