// GeneraWindowController.swift
// Copyright (c) 2020 Dylan Gattey

import AppKit
import GeneraGame

/// Owns the views in the app and starts the game controller after an event loop on app start
class GeneraWindowController: NSWindowController {
    /// The controller running the game - should always exist but optional for safety
    private var gameViewController: GameViewController?

    /// The controller in charge of the sidebar - should always exist but optional for safety
    private var sidePanelViewController: SidePanelViewController?

    /// The content view controller for the whole app
    private var appViewController: AppViewController?

    /// A toolbar item for the sidebar collapsing
    private var collapseSidebarToolbarItem: NSToolbarItem = {
        let item = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier(rawValue: toolbarItemToggleSidebar))
        item.image = NSImage(systemSymbolName: "sidebar.left", accessibilityDescription: "Toggle sidebar")
        item.action = #selector(toggleSidebar)
        return item
    }()

    /// A toolbar item for changing the game type
    private var gameTypeToolbarItem: NSToolbarItem = {
        let item = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier(rawValue: toolbarItemGameType))
        item.view = buildGameTypeSelector()
        return item
    }()

    /// Sets up whole app, using the next run loop to make sure the window has resized at least once before creating the coordinator
    override func windowDidLoad() {
        super.windowDidLoad()
        guard let contentViewController = window?.contentViewController,
              let gameViewController: GameViewController = firstViewController(in: contentViewController),
              let sidePanelViewController: SidePanelViewController = firstViewController(in: contentViewController),
              let startingGameType = GameType(rawValue: GameType.titles.first ?? "")
        else {
            assertionFailure("Views incorrectly set up")
            return
        }
        self.gameViewController = gameViewController
        self.sidePanelViewController = sidePanelViewController
        gameViewController.debugger = sidePanelViewController.debugger

        DispatchQueue.main.async {
            self.changeGameType(to: startingGameType)
        }
    }

    /// Finds the first view controller of a certain type in the given view controller to get around Storyboards being absolute shit
    private func firstViewController<T: NSViewController>(in parentController: NSViewController) -> T? {
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

    /// Actually changes the game type and orchestrates the sidebar change as a result
    private func changeGameType(to gameType: GameType) {
        gameViewController?.reset(to: gameType)
        sidePanelViewController?.resetViews(toIncludeConfigView: gameViewController?.currentConfigView)
    }
}

// MARK: - NSToolbarDelegate

extension GeneraWindowController: NSToolbarDelegate {
    /// The identifer for toggling the sidebar (custom button for it)
    private static let toolbarItemToggleSidebar = "dgattey.toggleSidebar"

    /// The identifer for the game type dropdown
    private static let toolbarItemGameType = "dgattey.gameType"

    /// Default items for the toolbar itself (all to left of sidebar divider)
    private static let defaultToolbarIDs: [NSToolbarItem.Identifier] =
        [NSToolbarItem.Identifier(toolbarItemGameType),
         .flexibleSpace,
         NSToolbarItem.Identifier(toolbarItemToggleSidebar),
         .sidebarTrackingSeparator]

    /// Builds a selector for game mode out of all possible game modes - if this grows, will have to do a different kind of control
    private static func buildGameTypeSelector() -> NSView {
        let selector = NSPopUpButton()
        for title in GameType.titles {
            selector.addItem(withTitle: title)
        }
        selector.action = #selector(GeneraWindowController.didChangeGameType)
        return selector
    }

    func toolbarDefaultItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
        GeneraWindowController.defaultToolbarIDs
    }

    func toolbarAllowedItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
        GeneraWindowController.defaultToolbarIDs
    }

    /// Creates the right data for the game type selector and the sidebar toggle
    func toolbar(_: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar _: Bool) -> NSToolbarItem?
    {
        let item: NSToolbarItem
        switch itemIdentifier {
        case NSToolbarItem.Identifier(GeneraWindowController.toolbarItemToggleSidebar):
            item = collapseSidebarToolbarItem
        case NSToolbarItem.Identifier(GeneraWindowController.toolbarItemGameType):
            item = gameTypeToolbarItem
        default:
            item = NSToolbarItem(itemIdentifier: itemIdentifier)
        }
        item.view?.translatesAutoresizingMaskIntoConstraints = false
        item.target = self
        item.menuFormRepresentation = nil
        return item
    }

    /// Called in response to changing the game type from the toolbar - changes it on the gameViewController
    @objc func didChangeGameType(_ sender: AnyObject) {
        guard let selector = sender as? NSPopUpButton else {
            return
        }
        let selectedItem = selector.indexOfSelectedItem
        if let gameType = GameType(rawValue: GameType.titles[selectedItem]) {
            changeGameType(to: gameType)
        }
    }

    /// Shows or hides the sidebar by calling the split view's toggle method
    @objc func toggleSidebar(_: AnyObject) {
        NSApp.keyWindow?.contentViewController?.tryToPerform(#selector(appViewController?.toggleSidebar(_:)),
                                                             with: nil)
    }
}
