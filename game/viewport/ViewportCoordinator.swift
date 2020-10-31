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
    
    /// All zoom levels
    private struct ZoomLevel {
        
        /// Minimum zoom supported
        static let min: Double = 0.2
        
        /// Max zoom supported
        static let max: Double = 3.0
        
        /// The multiplier on the zoom amount
        static let multiplier = 0.01
    }

    // MARK: variables
    
    /// This is the user position, including zooming and translation
    private var userPosition: MTLViewport = MTLViewport()
    
    /// This is the viewport for drawing, not including translation
    private(set) var currentViewport: MTLViewport = MTLViewport()
    
    /// The current zoom level, within the min and max range
    private var currentZoomLevel: Double = 1.0
    
    weak var mapUpdateDelegate: MapUpdateDelegate?

    /// Convenience function for resizing a viewport to another size
    private static func viewport(byResizing viewport: MTLViewport,
                                 to size: CGSize,
                                 atZoom zoomMultiplier: Double = 1.0) -> MTLViewport {
        return MTLViewport(
            originX: viewport.originX,
            originY: viewport.originY,
            width: Double(size.width) * zoomMultiplier,
            height: Double(size.height) * zoomMultiplier,
            znear: viewport.znear,
            zfar: viewport.zfar)
    }
    
    /// Convenience function for translating a viewport to another location
    private static func viewport(byTranslating viewport: MTLViewport,
                                 in directions: [Direction],
                                 atZoom zoomMultiplier: Double = 1.0) -> MTLViewport {
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
                x += amount * zoomMultiplier
            case .west:
                x -= amount * zoomMultiplier
            case .north:
                y += amount * zoomMultiplier
            case .south:
                y -= amount * zoomMultiplier
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
        userPosition = ViewportCoordinator.viewport(byTranslating: userPosition, in: directions, atZoom: currentZoomLevel)
        mapUpdateDelegate?.didUpdateUserPosition(to: userPosition)
    }
    
    /// Resize both the user position and the actual viewport
    func resizeViewport(to size: CGSize) {
        userPosition = ViewportCoordinator.viewport(byResizing: userPosition, to: size, atZoom: currentZoomLevel)
        currentViewport = ViewportCoordinator.viewport(byResizing: currentViewport, to: size)
        mapUpdateDelegate?.didUpdateUserPosition(to: userPosition)
    }
}
