//
//  Color.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import Cocoa
import simd

/// Useful color function manipulations
extension BiomeType {
    
    /// Converts a color into its components, as a simd_float4
    static func components(from color: NSColor) -> simd_float4 {
        return simd_float4(
            Float(color.redComponent),
            Float(color.greenComponent),
            Float(color.blueComponent),
            Float(color.alphaComponent)
        )
    }

}
