//
//  VertexProtocol.swift
//  Genera
//
//  Created by Dylan Gattey on 11/3/20.
//

import Foundation

/// Defines a reusable vertex type our shared vertices can use
protocol VertexProtocol {
    
    /// The position of this vertex
    var position: simd_float2 { get }

}

// MARK: - extensions to conform to VertexProtocol

extension GridVertex: VertexProtocol {}
extension TerrainVertex: VertexProtocol {}
