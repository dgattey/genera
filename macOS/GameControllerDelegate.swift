// GameControllerDelegate.swift
// Copyright (c) 2020 Dylan Gattey

import Foundation

/// Called by the `GameViewController` in response to game events
protocol GameControllerDelegate: AnyObject {
    /// Called when the game controller wants to reset the data provider
    func gameController<T: ShaderDataProviderProtocol>(hasNewDataProvider dataProvider: T?)
}
