//
//  ConfigView.swift
//  Genera
//
//  Created by Dylan Gattey on 11/8/20.
//

import AppKit

/// Represents a view we can use for configuration
protocol ConfigView: NSView, ShaderDataProvider {
    
    /// Weakly held update delegate for use with sending updates out
    var updateDelegate: ConfigUpdateDelegate? { get set }
    
}
