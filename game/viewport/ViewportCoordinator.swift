//
//  ViewportCoordinator.swift
//  Genera
//
//  Created by Dylan Gattey on 10/29/20.
//

import Metal

/// ViewportCoordinator functions for use with Metal manipulations
class ViewportCoordinator: NSObject, ViewportDataDelegate {
    
    // MARK: constants
    
    /// The amount by which to translate in pixels when using keyboard or mouse
    private static let translationStep: Double = 10
    
    /// The amount by which to translate on a diagonal in pixels when using keyboard
    /// or mouse, resulting in the same diagonal movement when applied to both the
    /// horizontal and the vertical translation
    private static let diagonalTranslationStep: Double = translationStep * sin(45)
    
    // MARK: variables
    
    /// This is the user position, including zooming and translation
    private var userPosition: MTLViewport = MTLViewport()
    
    /// This is the viewport for drawing, not including translation
    private(set) var currentViewport: MTLViewport = MTLViewport()
    
    weak var mapUpdateDelegate: MapUpdateDelegate?

    /// Convenience function for resizing a viewport to another size
    private static func viewport(byResizing viewport: MTLViewport, to size: CGSize) -> MTLViewport {
        return MTLViewport(
            originX: viewport.originX,
            originY: viewport.originY,
            width: Double(size.width),
            height: Double(size.height),
            znear: viewport.znear,
            zfar: viewport.zfar)
    }
    
    /// Convenience function for translating a viewport to another location
    private static func viewport(byTranslating viewport: MTLViewport, in directions: [Direction]) -> MTLViewport {
        if directions.isEmpty {
            assertionFailure("No directions to translate")
            return viewport
        }
        
        var x = viewport.originX
        var y = viewport.originY
        
        // Normalize by number of directions we're moving in, otherwise we move too fast
        let amount = directions.count == 2 ? diagonalTranslationStep : translationStep
        for direction in directions {
            switch direction {
            case .east:
                x += amount
            case .west:
                x -= amount
            case .north:
                y += amount
            case .south:
                y -= amount
            }
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

extension ViewportCoordinator: ViewportChangeDelegate {
    
    /// Change the user position only, not the actual viewport
    func panViewport(_ directions: [Direction]) {
        userPosition = ViewportCoordinator.viewport(byTranslating: userPosition, in: directions)
        mapUpdateDelegate?.didUpdateUserPosition(to: userPosition)
    }
    
    /// Resize both the user position and the actual viewport
    func resizeViewport(to size: CGSize) {
        userPosition = ViewportCoordinator.viewport(byResizing: userPosition, to: size)
        currentViewport = ViewportCoordinator.viewport(byResizing: currentViewport, to: size)
        mapUpdateDelegate?.didUpdateUserPosition(to: userPosition)
    }
}
