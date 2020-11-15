// TerrainPresetDelegate.swift
// Copyright (c) 2020 Dylan Gattey
// Created by Dylan Gattey on 11/8/20.

import Foundation

/// Things the terrain preset view alerts about
protocol TerrainPresetDelegate: AnyObject {
    /// Called when the user selects the given preset
    func selectPreset(_ preset: TerrainData)

    /// Called when the user wants to save the current data as a preset, with a callback function
    func saveCurrentDataAsPreset(named name: String, onCompletion: @escaping (_ presetName: String) -> Void)
}
