//
//  ShaderDataProtocol.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import Foundation

/// Defines a protocol for all config data shared between the shader and swift code conforms to. Exactly
/// one of these will be sent in MapRenderer to the shader
protocol ShaderDataProtocol {}

/// Extends existing shader with the protocol
extension TerrainShaderConfigData: ShaderDataProtocol {}

/// Empty class for use when I have no data to pass to the shader
class EmptyShaderData: ShaderDataProtocol {}
