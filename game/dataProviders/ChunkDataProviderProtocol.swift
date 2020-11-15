// ChunkDataProviderProtocol.swift
// Copyright (c) 2020 Dylan Gattey
// Created by Dylan Gattey on 10/30/20.

import Foundation

// A protocol any provider of chunk data must conform to
protocol ChunkDataProviderProtocol: NSObject {
    /// The type of data stored in the chunk data
    associatedtype ChunkDataType: ChunkDataProtocol

    /// The type of shader data provider associated with this provider
    associatedtype ShaderDataProviderType: ShaderDataProviderProtocol

    /// Which shader names to use in generation
    var shaders: (vertex: String, fragment: String) { get }

    /// If we have a shader data provider, this will return it
    var shaderDataProvider: ShaderDataProviderType? { get }

    /// Generates a block of ChunkData to use in some form
    func generateChunkData(for chunk: Chunk) -> [ChunkDataType]
}
