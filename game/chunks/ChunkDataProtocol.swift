//
//  ChunkDataProtocol.swift
//  Genera
//
//  Created by Dylan Gattey on 11/3/20.
//

import Foundation

/// Represents anything that can be stored as chunk data in a generator data provider
protocol ChunkDataProtocol: Hashable {
    
    associatedtype VertexType: VertexProtocol
    
    /// Get the vertices for this chunk of data
    var vertices: [VertexType] { get }
    
}
