//
//  ChunkGenerationState.swift
//  Genera
//
//  Created by Dylan Gattey on 11/1/20.
//

import Foundation

/// The state of generation for one chunk of data
enum ChunkGenerationState: Hashable {
    
    /// This chunks needs to be generated
    case needsGeneration
    
    /// This chunk is in the process of generating
    case isGenerating
    
    /// This chunk is fully generated
    case done
}
