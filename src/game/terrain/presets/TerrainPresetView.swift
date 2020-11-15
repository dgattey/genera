// TerrainPresetView.swift
// Copyright (c) 2020 Dylan Gattey

import AppKit
import Utility

/// Allows choosing different preset values for terrain that you can save and load at runtime
class TerrainPresetView: EditableValuesStackView {
    // MARK: - variables

    /// Collects preset name -> preset data groupings
    private var presets: [String: TerrainData] = [:]

    /// Called when things happen in the presets
    weak var presetDelegate: TerrainPresetDelegate?

    /// Allows choosing between different preset values as the fallback
    private lazy var presetChooser: NSPopUpButton = {
        let button = NSPopUpButton()
        button.controlSize = .large
        button.target = self
        button.action = #selector(selectPreset)
        button.addItem(withTitle: DefaultTerrainData.presetName)
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

    /// Remove the menu bar item we added if we're destroying this view
    deinit {
        if let menu = NSApp.menu,
           let index = menu.items.firstIndex(where: { $0.title == menubarPresetsMenu.title })
        {
            menu.removeItem(at: index)
        }
    }

    // MARK: - API

    /// Adds the correct views + reload presets to start with from disk
    func populatePresets() {
        reloadPresets()

        if let menu = NSApp.menu, !menu.items.contains(where: { $0.title == menubarPresetsMenu.title }) {
            menu.insertItem(menubarPresetsMenu, at: 1)
        }

        let presetChooserStack = NSStackView()
        presetChooserStack.distribution = .equalSpacing
        presetChooserStack.setClippingResistancePriority(.required, for: .horizontal)
        presetChooserStack.setHuggingPriority(.fittingSizeCompression, for: .horizontal)
        presetChooserStack.addView(presetChooser, in: .leading)
        presetChooserStack.addView(actionsMenuButton, in: .trailing)
        addView(presetChooserStack, in: .bottom)
    }

    /// Opens the actions menu from the button
    @objc func openActionsMenu() {
        actionsMenu.popUp(positioning: nil,
                          at: actionsMenuButton.frame.origin,
                          in: self)
    }

    /// Reloads all presets into the main array onto a background thread, then reloads the preset chooser
    @objc func reloadPresets() {
        reloadPresetsAndReset(bySelecting: DefaultTerrainData.presetName)
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
            presetDelegate?.selectPreset(preset)
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
                                         placeholder: "My Favorite Map") { name, success in
            guard success else {
                return
            }
            self.presetDelegate?.saveCurrentDataAsPreset(named: name, onCompletion: { [weak self] presetName in
                self?.reloadPresetsAndReset(bySelecting: presetName)
            })
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
    private func reloadPresetsAndReset(bySelecting presetName: String) {
        let resetPicker = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let keys = Array(strongSelf.presets.keys).sorted()
            strongSelf.presetChooser.removeAllItems()
            strongSelf.presetChooser.addItems(withTitles: keys)
            strongSelf.presetChooser.selectItem(withTitle: presetName)
        }
        let handlePresets = { [weak self] (presets: [TerrainData]) in
            let keys = presets.map { $0.presetName }
            self?.presets = Dictionary(uniqueKeysWithValues: zip(keys, presets))
            DispatchQueue.main.async {
                resetPicker()
            }
        }
        DispatchQueue.global(qos: .utility).async {
            TerrainPresetLoader.loadPresets(completion: handlePresets)
        }
    }
}
