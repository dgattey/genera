//
//  ShaderDataProviderProtocol.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import Foundation

// A protocol any provider of shader config data must conform to
protocol ShaderDataProviderProtocol: AnyObject {
    /// The type of data stored in by this provider
    associatedtype ShaderDataType: ShaderDataProtocol

    /// Weakly held update delegate for use with sending updates out
    var updateDelegate: ConfigUpdateDelegate? { get set }

    /// Returns an instance of config data for use with passing to shader
    var configData: ShaderDataType { get }

    /// Returns all biomes for use with passing to shader
    var allBiomes: [Biome] { get }
}

extension ShaderDataProviderProtocol {
    /// Deterministically turns a seed into a uint for use with creation of config data
    static func seed(from seed: String) -> uint {
        let scalars = seed.unicodeScalars.map { $0.value }
        return scalars.reduce(83761) { scalar, result in
            (scalar << 5) &+ scalar &+ uint(result)
        }
    }
}

/// Used for no data views
class EmptyShaderDataProvider: ShaderDataProviderProtocol {
    var updateDelegate: ConfigUpdateDelegate? {
        set {}
        get { nil }
    }

    var configData: EmptyShaderData {
        fatalError("Cannot be constructed")
    }

    var allBiomes: [Biome] {
        fatalError("Cannot be constructed")
    }
}
