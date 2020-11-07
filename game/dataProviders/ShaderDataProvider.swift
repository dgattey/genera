//
//  ShaderDataProvider.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import Foundation

// A protocol any provider of shader config data must conform to
protocol ShaderDataProvider: NSObject {
    
    /// The type of data stored in by this provider
    associatedtype ShaderConfigDataType: ShaderConfigDataProtocol
    
    /// Returns an instance of config data for use with passing to shader
    var configData: ShaderConfigDataType { get }
    
    /// Returns all biomes for use with passing to shader
    var allBiomes: [Biome] { get }
    
}
