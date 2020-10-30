//
//  Utility.swift
//  Genera
//
//  Created by Dylan Gattey on 10/29/20.
//

import Metal

// Utility functions for use with Metal manipulations
class Utility {

    // Convenience function for creating a Viewport from a regular CGSize
    static func viewport(from size: CGSize) -> MTLViewport {
        return MTLViewport(
            originX: 0.0,
            originY: 0.0,
            width: Double(size.width),
            height: Double(size.height),
            znear: 0.0,
            zfar: 1.0)
    }

}
