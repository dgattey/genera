//
//  GameControllerDelegate.swift
//  Genera
//
//  Created by Dylan Gattey on 11/8/20.
//

import Foundation

/// Called by the `GameViewController` in response to game events
protocol GameControllerDelegate: class {
    
    /// Called when the game controller wants to reset the data provider
    func gameController<T: ShaderDataProvider>(hasNewDataProvider dataProvider: T?)
    
}
