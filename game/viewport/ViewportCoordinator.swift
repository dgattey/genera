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
    
    private static let translationStep: Double = 20
    
    // MARK: variables
    
    private var userPosition: MTLViewport = MTLViewport()
    internal var currentViewport: MTLViewport = MTLViewport()
    internal weak var mapUpdateDelegate: MapUpdateDelegate?

    /// Convenience function for creating a Viewport from a regular CGSize
    private static func viewport(byResizing viewport: MTLViewport, to size: CGSize) -> MTLViewport {
        return MTLViewport(
            originX: viewport.originX,
            originY: viewport.originY,
            width: Double(size.width),
            height: Double(size.height),
            znear: viewport.znear,
            zfar: viewport.zfar)
    }
    
    /// Convenience function for translating a viewport
    private static func viewport(byTranslating viewport: MTLViewport, inDirection direction: Direction) -> MTLViewport {
        var x = viewport.originX
        var y = viewport.originY
        switch direction {
        case .east:
            x += translationStep
        case .west:
            x -= translationStep
        case .north:
            y += translationStep
        case .south:
            y -= translationStep
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
    func panViewport(_ direction: Direction) {
        userPosition = ViewportCoordinator.viewport(byTranslating: userPosition, inDirection: direction)
        mapUpdateDelegate?.didUpdateUserPosition(to: userPosition)
    }
    
    /// Resize both the user position and the actual viewport
    func resizeViewport(to size: CGSize) {
        userPosition = ViewportCoordinator.viewport(byResizing: userPosition, to: size)
        currentViewport = ViewportCoordinator.viewport(byResizing: currentViewport, to: size)
        mapUpdateDelegate?.didUpdateUserPosition(to: userPosition)
    }
}
