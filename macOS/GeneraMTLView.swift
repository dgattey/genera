//
//  GeneraMTLView.swift
//  Genera
//
//  Created by Dylan Gattey on 10/31/20.
//

import Foundation
import MetalKit

/// Defines an MTKView class with a viewport change delegate
protocol GeneraMTLView: MTKView {
    
    /// The weakly-held viewport change delegate to notify with changes
    var viewportDelegate: ViewportChangeDelegate? { get set }
    
}
