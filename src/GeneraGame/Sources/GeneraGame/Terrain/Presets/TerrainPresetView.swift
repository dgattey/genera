// TerrainPresetView.swift
// Copyright (c) 2020 Dylan Gattey

import AppKit
import Combine
import Debug
import Engine
import UI

/// Allows choosing different preset values for terrain that you can save and load at runtime
class TerrainPresetView: EditableValuesStackView {
    // MARK: - types

    /// Possible actions a user can take on this view for someone to listen to
    enum Action {
        /// Marks a preset as selected with some given data
        case selectPreset(withData: TerrainPresetData)

        /// Saves the current data as a preset with the given name, using a callback function when done
        case saveCurrentData(asPresetNamed: String, onCompletion: (String?) -> Void)
    }

    // MARK: - constants

    /// The index of the preset menu in the main NSApp titlebar menu
    private static let presetAppMenuIndex = 1

    // MARK: - variables

    /// Collects preset name -> preset data groupings
    private var presets: [String: TerrainPresetData] = [:]

    /// Used to keep track of the publisher loading presets
    private var loadPresetsCancellable: AnyCancellable?

    /// Publishes actions to anyone who wants to listen
    private let publisher = PassthroughSubject<Action, Never>()

    /// Allows choosing between different preset values as the fallback
    private lazy var presetChooser: NSPopUpButton = {
        let button = NSPopUpButton()
        button.controlSize = .large
        button.target = self
        button.action = #selector(selectPreset)
        button.addItem(withTitle: "Loading...")
        button.isEnabled = false
        return button
    }()

    /// All actions to show in the actions menu from the button
    private lazy var actionsMenu: NSMenu = {
        let menu = NSMenu(title: "Actions")
        menu.items = [saveItem(), reloadItem(), openItem()]
        return menu
    }()

    /// All actions to show in the menubar under the presets menu
    private lazy var menubarPresetsMenu: NSMenuItem = {
        let item = NSMenuItem()
        let menu = NSMenu(title: "Presets")
        menu.items = [saveItem(), reloadItem(), openItem()]
        item.submenu = menu
        return item
    }()

    /// The button that shows the actions menu
    private lazy var actionsMenuButton: NSButton = {
        let actionButton = NSButton(frame: .zero)
        actionButton.controlSize = .large
        actionButton.bezelStyle = .circular
        actionButton.target = self
        actionButton.action = #selector(openActionsMenu)
        actionButton.image = NSImage(systemSymbolName: "ellipsis", accessibilityDescription: "More Actions")?
            .withSymbolConfiguration(NSImage.SymbolConfiguration(scale: .large))
        actionButton.menu = actionsMenu
        return actionButton
    }()

    // MARK: - API

    /// Adds and removes the menu item for Presets when the view is added/removed from a parent
    override func viewDidMoveToSuperview() {
        guard let menu = NSApp.menu, menu.items.count > 2 else {
            return
        }
        let representedObject = menu.items[TerrainPresetView.presetAppMenuIndex].representedObject as? TerrainPresetView

        // We want to remove the existing menu bar item if one exists - either because we're moving away from this view
        // entirely, or because we want to add a new item with updated targets so we can handle the ⌘ commands
        if let representedObject = representedObject,
           superview == nil && representedObject === self || superview != nil && representedObject !== self
        {
            menu.removeItem(at: TerrainPresetView.presetAppMenuIndex)
        }

        // Add the menu item if we're moving to a new view, tracking which view added it with representedObject
        if superview != nil {
            menubarPresetsMenu.representedObject = self
            menu.insertItem(menubarPresetsMenu, at: TerrainPresetView.presetAppMenuIndex)
        }
    }

    /// Adds the correct views + reload presets to start with from disk
    func populatePresets() {
        let presetChooserStack = NSStackView()
        presetChooserStack.distribution = .equalSpacing
        presetChooserStack.setClippingResistancePriority(.required, for: .horizontal)
        presetChooserStack.setHuggingPriority(.fittingSizeCompression, for: .horizontal)
        presetChooserStack.addView(presetChooser, in: .leading)
        presetChooserStack.addView(actionsMenuButton, in: .trailing)
        addView(presetChooserStack, in: .bottom)

        reloadPresetsAndReset()
    }

    /// Opens the actions menu from the button
    @objc func openActionsMenu() {
        actionsMenu.popUp(positioning: nil,
                          at: actionsMenuButton.frame.origin,
                          in: self)
    }

    /// Reloads all presets into the main array onto a background thread, then reloads the preset chooser
    @objc func reloadPresets() {
        reloadPresetsAndReset()
    }

    /// Opens the presets folder in Finder
    @objc func openPresetsFolder() {
        NSWorkspace.shared.open(TerrainPresetLoader.presetsFolderURL)
    }

    /// Selects a given preset from the list
    @objc func selectPreset(_ sender: AnyObject?) {
        if let popupButton = sender as? NSPopUpButton,
           let menuItem = popupButton.selectedItem,
           let preset = presets[menuItem.title]
        {
            publisher.send(.selectPreset(withData: preset))
        }
    }

    /// Delegates to save the current settings as a new preset
    @objc func savePreset(_: AnyObject?) {
        guard let window = window else {
            assertionFailure("Missing window")
            return
        }
        WindowCoordinator.promptForReply(from: window,
                                         withTitle: "Save as...",
                                         details: "Name your preset to finish saving it",
                                         placeholder: "My Favorite Map") { [unowned self] name, success in
            guard success else {
                return
            }
            publisher.send(.saveCurrentData(asPresetNamed: name, onCompletion: reloadPresetsAndReset))
        }
    }

    // MARK: - private helpers

    /// Exposes a button to save current settings
    private func saveItem() -> NSMenuItem {
        let item = NSMenuItem()
        item.title = "Save current settings as a new preset..."
        item.keyEquivalent = "s"
        item.keyEquivalentModifierMask = .command
        item.image = NSImage(systemSymbolName: "square.and.arrow.down.fill", accessibilityDescription: item.title)?
            .withSymbolConfiguration(NSImage.SymbolConfiguration(scale: .medium))
        item.target = self
        item.action = #selector(savePreset)
        return item
    }

    /// Reloads the presets from disk
    private func reloadItem() -> NSMenuItem {
        let item = NSMenuItem()
        item.title = "Reload presets"
        item.keyEquivalent = "r"
        item.keyEquivalentModifierMask = .command
        item.image = NSImage(systemSymbolName: "arrow.triangle.2.circlepath", accessibilityDescription: item.title)?
            .withSymbolConfiguration(NSImage.SymbolConfiguration(scale: .medium))
        item.target = self
        item.action = #selector(reloadPresets)
        return item
    }

    /// Opens the Finder folder where the presets live
    private func openItem() -> NSMenuItem {
        let item = NSMenuItem()
        item.title = "Open presets folder in Finder..."
        item.keyEquivalent = "o"
        item.keyEquivalentModifierMask = .command
        item.image = NSImage(systemSymbolName: "folder.fill", accessibilityDescription: item.title)?
            .withSymbolConfiguration(NSImage.SymbolConfiguration(scale: .medium))
        item.target = self
        item.action = #selector(openPresetsFolder)
        return item
    }

    /// Reloads all presets into the main array onto a background thread, then reloads the preset chooser
    private func reloadPresetsAndReset(bySelecting presetName: String? = nil) {
        let resetPicker = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let keys = Array(strongSelf.presets.keys).sorted()
            guard !keys.isEmpty else {
                assertionFailure("No presets!")
                return
            }
            let previousSelectedItem = strongSelf.presetChooser.selectedItem?.title
            strongSelf.presetChooser.removeAllItems()
            strongSelf.presetChooser.addItems(withTitles: keys)

            // Choose either the given preset, the previous item, or the default preset
            if let presetName = presetName, keys.contains(presetName) {
                strongSelf.presetChooser.selectItem(withTitle: presetName)
            } else if let previousSelectedItem = previousSelectedItem, keys.contains(previousSelectedItem) {
                strongSelf.presetChooser.selectItem(withTitle: previousSelectedItem)
            } else {
                strongSelf.presetChooser.selectItem(withTitle: TerrainPresetData.default.presetName)
            }
            strongSelf.selectPreset(strongSelf.presetChooser)
            strongSelf.presetChooser.isEnabled = true
        }

        // Load more
        loadPresetsCancellable?.cancel()
        loadPresetsCancellable = TerrainPresetLoader.loadPresets().sink { result in
            if case let .failure(error) = result {
                Logger.log(error)
            }
        } receiveValue: { [weak self] namedPresets in
            self?.presets = namedPresets
            resetPicker()
        }
    }
}

/// Allows us to actually use this view as a publisher
extension TerrainPresetView: Publisher {
    typealias Output = Action
    typealias Failure = Never

    func receive<S>(subscriber: S)
        where S: Subscriber,
        TerrainPresetView.Failure == S.Failure,
        TerrainPresetView.Output == S.Input
    {
        publisher.subscribe(subscriber)
    }
}
