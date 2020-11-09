//
//  ShaderDataProtocol.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import Foundation

/// Defines a protocol for all config data shared between the shader and swift code conforms to. Exactly
/// one of these will be sent in MapRenderer to the shader
protocol ShaderDataProtocol {
    
    /// The number of biomes we'll pass to the shader
    var numBiomes: Int32 { get }
}

/// Used for shaders that don't have configuration data - dummy class
class EmptyShaderData: ShaderDataProtocol {
    
    var numBiomes: Int32 {
        fatalError("Should not be called ever")
    }
}

extension TerrainShaderConfigData: ShaderDataProtocol {}
