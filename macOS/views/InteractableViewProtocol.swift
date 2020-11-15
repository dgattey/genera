//
//  InteractableViewProtocol.swift
//  Genera
//
//  Created by Dylan Gattey on 10/31/20.
//

import Foundation
import MetalKit

/// Defines an MTKView class with a viewport change delegate
protocol InteractableViewProtocol: MTKView {
    /// The weakly-held user interaction delegate to call when the user interacts
    var userInteractionDelegate: UserInteractionDelegate? { get set }
}
