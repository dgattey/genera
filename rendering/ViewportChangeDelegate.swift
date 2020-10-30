//
//  ViewportChangeDelegate.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import Foundation

// Handles changes that should be made to the viewport
protocol ViewportChangeDelegate: NSObject {
    
    // Pans in a given direction
    func pan(in direction: Direction) -> Void

}
