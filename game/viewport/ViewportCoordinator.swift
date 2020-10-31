//
//  ViewportCoordinator.swift
//  Genera
//
//  Created by Dylan Gattey on 10/29/20.
//

import Metal

// ViewportCoordinator functions for use with Metal manipulations
class ViewportCoordinator: NSObject, ViewportDataDelegate {
    
    // MARK: constants
    
    private static let translationStep: Double = 20
    
    // MARK: variables
    
    private var translatedViewport: MTLViewport = MTLViewport()
    internal var untranslatedViewport: MTLViewport = MTLViewport()
    internal weak var mapUpdateDelegate: MapUpdateDelegate?

    // Convenience function for creating a Viewport from a regular CGSize
    private static func viewport(byResizing viewport: MTLViewport, to size: CGSize) -> MTLViewport {
        return MTLViewport(
            originX: viewport.originX,
            originY: viewport.originY,
            width: Double(size.width),
            height: Double(size.height),
            znear: viewport.znear,
            zfar: viewport.zfar)
    }
    
    // Convenience function for translating a viewport
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
    func panViewport(_ direction: Direction) {
        translatedViewport = ViewportCoordinator.viewport(byTranslating: translatedViewport, inDirection: direction)
        mapUpdateDelegate?.didUpdateViewport(to: translatedViewport)
    }
    
    func resizeViewport(to size: CGSize) {
        translatedViewport = ViewportCoordinator.viewport(byResizing: translatedViewport, to: size)
        untranslatedViewport = ViewportCoordinator.viewport(byResizing: untranslatedViewport, to: size)
        mapUpdateDelegate?.didUpdateViewport(to: translatedViewport)
    }
}
