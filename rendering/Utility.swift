//
//  Utility.swift
//  Genera
//
//  Created by Dylan Gattey on 10/29/20.
//

import Metal

// Utility functions for use with Metal manipulations
class Utility {
    
    private static let translationStep: Double = 5

    // Convenience function for creating a Viewport from a regular CGSize
    static func viewport(byResizing viewport: MTLViewport, to size: CGSize) -> MTLViewport {
        return MTLViewport(
            originX: viewport.originX,
            originY: viewport.originY,
            width: Double(size.width),
            height: Double(size.height),
            znear: viewport.znear,
            zfar: viewport.zfar)
    }
    
    // Convenience function for translating a viewport
    static func viewport(byTranslating viewport: MTLViewport, inDirection direction: Direction) -> MTLViewport {
        var x = viewport.originX
        var y = viewport.originY
        switch direction {
        case .east:
            x += translationStep
        case .west:
            x -= translationStep
        case .north:
            y -= translationStep
        case .south:
            y += translationStep
        }
        return MTLViewport(
            originX: x,
            originY: y,
            width: viewport.width,
            height: viewport.height,
            znear: viewport.znear,
            zfar: viewport.zfar)
    }

}
