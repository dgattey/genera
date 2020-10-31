//
//  GenerationDelegate.swift
//  Genera
//
//  Created by Dylan Gattey on 10/31/20.
//

import Foundation

/// This delegate notifies the generator to do certain things
protocol GenerationDelegate {
    
    /// Starts generating the map itselff
    func startMapGeneration() -> Void

}
