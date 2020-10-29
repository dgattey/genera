//
//  Generator.swift
//  Land macOS
//
//  Created by Dylan Gattey on 10/28/20.
//

import Foundation
import Metal
import MetalKit

class Generator {
    
    /**
     Create generic 4x4 matrix for the land, to start
     */
    static func initialize() -> matrix_float4x4 {
        return matrix_float4x4(diagonal: SIMD4<Float>(0.4, 1.0, 0.5, 0.8))
    }
    
}
