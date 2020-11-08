//
//  GameControllerDelegate.swift
//  Genera
//
//  Created by Dylan Gattey on 11/8/20.
//

import Foundation

/// Called by the `GameViewController` in response to game events
protocol GameControllerDelegate: class {
    
    /// Called when the game controller wants to add a new config view
    func gameControllerDidAdd<T: ConfigView>(configView: T)
    
}
