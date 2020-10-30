//
//  GeneratorChangeDelegate.swift
//  Genera
//
//  Created by Dylan Gattey on 10/29/20.
//

import Foundation

// A delegate for use with all generators to be notifed of action
protocol GeneratorChangeDelegate: NSObject {

    // Called when a chunk has updated tiles to use
    func didUpdateTiles(in chunk: Chunk) -> Void
    
}
