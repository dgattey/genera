//
//  TerrainPresetView.swift
//  Genera
//
//  Created by Dylan Gattey on 11/8/20.
//

import AppKit

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
        button.target = self
        button.action = #selector(selectPreset)
        return button
    }()
    
    /// Exposes a button to save current settings
    private lazy var saveButton: NSButton = {
        let button = NSButton()
        button.setButtonType(.momentaryPushIn)
        button.bezelStyle = .rounded
        button.title = "Save Current Settings"
        button.target = self
        button.action = #selector(savePreset)
        button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return button
    }()
    
    /// Reloads the presets from disk
    private lazy var reloadButton: NSButton = {
        let reloadButton = NSButton()
        reloadButton.setButtonType(.momentaryPushIn)
        reloadButton.bezelStyle = .rounded
        reloadButton.title = "Reload"
        reloadButton.target = self
        reloadButton.action = #selector(reloadPresets)
        reloadButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return reloadButton
    }()
    
    /// Opens the Finder folder where the presets live
    private lazy var openButton: NSButton = {
        let button = NSButton()
        button.setButtonType(.momentaryPushIn)
        button.bezelStyle = .rounded
        button.title = "Open folder"
        button.target = self
        button.action = #selector(openPresetsFolder)
        return button
    }()
    
    // MARK: - API
    
    /// Adds the correct views + reload presets to start with from disk
    func populatePresets() {
        reloadPresets()
        
        // The chooser itself
        let presetChooserStack = NSStackView()
        presetChooserStack.distribution = .fill
        presetChooserStack.addView(presetChooser, in: .leading)
        presetChooserStack.addView(saveButton, in: .trailing)
        addView(presetChooserStack, in: .bottom)
        
        // Helper text + buttons to open presets folder + reset
        LabeledView.addLabel("Presets located at:\n\(TerrainPresetLoader.presetsFolderPath)", style: .field, toStack: self)
        let buttonsStack = NSStackView()
        buttonsStack.distribution = .fill
        buttonsStack.addView(openButton, in: .leading)
        buttonsStack.addView(reloadButton, in: .trailing)
        addView(buttonsStack, in: .bottom)
    }
    
    /// Reloads all presets into the main array onto a background thread, then reloads the preset chooser
    @objc func reloadPresets() {
        reloadPresetsAndReset(bySelecting: DefaultTerrainData.presetName)
    }
    
    /// Opens the presets folder in Finder
    @objc func openPresetsFolder() {
        NSWorkspace.shared.openFile(TerrainPresetLoader.presetsFolderPath)
    }
    
    /// Selects a given preset from the list
    @objc func selectPreset(_ sender: AnyObject?) {
        if let popupButton = sender as? NSPopUpButton,
           let menuItem = popupButton.selectedItem,
           let preset = presets[menuItem.title] {
            presetDelegate?.selectPreset(preset)
        }
    }
    
    /// Delegates to save the current settings as a new preset
    @objc func savePreset(_ sender: AnyObject?) {
        guard let window = window else {
            assertionFailure("Missing window")
            return
        }
        AppDelegate.promptForReply(from: window,
                                   withTitle: "Save as...",
                                   details: "Name your preset to finish saving it",
                                   placeholder: "My Favorite Map") { (name, success) in
            guard success else {
                return
            }
            self.presetDelegate?.saveCurrentDataAsPreset(named: name, onCompletion: { [weak self] presetName in
                self?.reloadPresetsAndReset(bySelecting: presetName)
            })
        }
        
    }
    
    // MARK: - private helpers
    
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
            let keys = presets.map({ $0.presetName })
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
