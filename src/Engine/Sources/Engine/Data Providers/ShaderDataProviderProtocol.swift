// ShaderDataProviderProtocol.swift
// Copyright (c) 2022 Dylan Gattey

import Combine
import EngineCore
import EngineData
import Foundation

// A protocol any provider of shader config data must conform to
public protocol ShaderDataProviderProtocol: AnyObject {
    /// The type of data stored in by this provider
    associatedtype ShaderDataType: ShaderDataProtocol

    /// Casts this object to a publisher if possible
    var asPublisher: AnyPublisher<EditableConfigAction, Never>? { get }

    /// Returns an instance of config data for use with passing to shader
    var configData: ShaderDataType { get }

    /// Returns all biomes for use with passing to shader
    var allBiomes: [Biome] { get }
}

public extension ShaderDataProviderProtocol {
    /// Deterministically turns a seed into a uint for use with creation of config data
    static func seed(from seed: String) -> uint {
        let scalars = seed.unicodeScalars.map(\.value)
        return scalars.reduce(83761) { scalar, result in
            (scalar << 5) &+ scalar &+ uint(result)
        }
    }
}

/// Used for no data views
public class EmptyShaderDataProvider: ShaderDataProviderProtocol {
    public var asPublisher: AnyPublisher<EditableConfigAction, Never>? {
        nil
    }

    public var configData: EmptyShaderData {
        fatalError("Cannot be constructed")
    }

    public var allBiomes: [Biome] {
        fatalError("Cannot be constructed")
    }
}
