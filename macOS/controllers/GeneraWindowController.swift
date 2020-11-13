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

    /// The identifer for toggling the sidebar (custom button for it)
    private static let toolbarItemToggleSidebar = "dgattey.toggleSidebar"
    
    /// The identifer for the game type dropdown
    private static let toolbarItemGameType = "dgattey.gameType"
    
    /// Default items for the toolbar itself (all to left of sidebar divider)
    private static let defaultToolbarIDs: [NSToolbarItem.Identifier] = [
        NSToolbarItem.Identifier(toolbarItemGameType),
        .flexibleSpace,
        NSToolbarItem.Identifier(toolbarItemToggleSidebar),
        .sidebarTrackingSeparator,
    ]
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return GeneraWindowController.defaultToolbarIDs
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return GeneraWindowController.defaultToolbarIDs
    }
    
    /// Creates the right data for the game type selector and the sidebar toggle
    func toolbar(_ toolbar: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case NSToolbarItem.Identifier(GeneraWindowController.toolbarItemToggleSidebar):
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.image = NSImage(systemSymbolName: "sidebar.left", accessibilityDescription: "Toggle sidebar")
            item.target = self
            item.action = #selector(toggleSidebar)
            return item
        case NSToolbarItem.Identifier(GeneraWindowController.toolbarItemGameType):
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.view = buildGameTypeSelector()
            return item
        default:
            return NSToolbarItem(itemIdentifier: itemIdentifier)
        }
    }
    
    /// Builds a selector for game mode out of all possible game modes - if this grows, will have to do a different kind of control
    private func buildGameTypeSelector() -> NSView {
        let selector = NSSegmentedControl()
        selector.segmentCount = GameType.titles.count
        for (index, title) in GameType.titles.enumerated() {
            selector.setLabel(title, forSegment: index)
        }
        selector.setSelected(true, forSegment: 0)
        selector.target = self
        selector.action = #selector(GeneraWindowController.didChangeGameType)
        selector.controlSize = .large
        return selector
    }
    
    /// Called in response to changing the game type from the toolbar - changes it on the gameViewController
    @objc func didChangeGameType(_ sender: AnyObject) {
        guard let segmentedControl = sender as? NSSegmentedControl else {
            return
        }
        let selectedItem = segmentedControl.selectedSegment
        if let gameType = GameType(rawValue: GameType.titles[selectedItem]) {
            gameViewController?.reset(to: gameType)
        }
    }
    
    /// Shows or hides the sidebar by calling the split view's toggle method
    @objc func toggleSidebar(_ sender: AnyObject) {
        NSApp.keyWindow?.contentViewController?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}
