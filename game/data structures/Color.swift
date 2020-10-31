//
//  Color.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import Cocoa

/// Useful color function manipulations
enum Color {
    
    /// Converts a color into its components, as a float array
    static func components(from color: NSColor) -> [Float] {
        return [
            Float(color.redComponent),
            Float(color.greenComponent),
            Float(color.blueComponent),
            Float(color.alphaComponent)
        ]
    }

}
