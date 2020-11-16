// InteractableViewProtocol.swift
// Copyright (c) 2020 Dylan Gattey

import Foundation
import MetalKit

/// Defines an MTKView class with a viewport change delegate
public protocol InteractableViewProtocol: MTKView {
    /// The weakly-held user interaction delegate to call when the user interacts
    var userInteractionDelegate: UserInteractionDelegate? { get set }
}
