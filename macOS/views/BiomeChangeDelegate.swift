//
//  BiomeChangeDelegate.swift
//  Genera
//
//  Created by Dylan Gattey on 11/13/20.
//

import Foundation

/// Called when changes to biomes happen
protocol BiomeChangeDelegate: class {
    
    /// Called when data for a biome changes for an identifier
    func biome(withIdentifier id: String, didUpdateTo biome: Biome)
}
