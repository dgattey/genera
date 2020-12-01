// VertexProtocol.swift
// Copyright (c) 2020 Dylan Gattey

import simd

/// Defines a reusable vertex type our shared vertices can use
public protocol VertexProtocol {
    /// The position of this vertex
    var position: simd_float2 { get }
}
