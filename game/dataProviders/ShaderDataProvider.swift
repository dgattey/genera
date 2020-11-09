//
//  ShaderDataProvider.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import Foundation

// A protocol any provider of shader config data must conform to
protocol ShaderDataProvider: class {
    
    /// The type of data stored in by this provider
    associatedtype ShaderConfigDataType: ShaderConfigDataProtocol
    
    /// Weakly held update delegate for use with sending updates out
    var updateDelegate: ConfigUpdateDelegate? { get set }
    
    /// Returns an instance of config data for use with passing to shader
    var configData: ShaderConfigDataType { get }
    
    /// Returns all biomes for use with passing to shader
    var allBiomes: [Biome] { get }
    
}

extension ShaderDataProvider {
    
    /// Deterministically turns a seed into a uint for use with creation of config data
    static func seed(from seed: String) -> uint {
        let scalars = seed.unicodeScalars.map { $0.value }
        return scalars.reduce(83761) { (scalar, result) in
            (scalar << 5) &+ scalar &+ uint(result)
        }
    }
    
}

/// Used for no data views
class EmptyShaderDataProvider: ShaderDataProvider {
    
    var updateDelegate: ConfigUpdateDelegate? {
        set {}
        get { return nil }
    }
    
    var configData: EmptyShaderData {
        fatalError("Cannot be constructed")
    }
    
    var allBiomes: [Biome] {
        fatalError("Cannot be constructed")
    }

}
