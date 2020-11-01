//
//  GameCoordinator.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import MetalKit

/**
 Coordinates all of the game generation, rendering, and viewports
 */
class GameCoordinator {
    
    // MARK: variables
    
    private let generator: GeneratorProtocol & GeneratorDataDelegate
    private let viewportCoordinator = ViewportCoordinator()
    private let renderer: MapRenderer
    
    // MARK: initialization
    
    /// Initialization will fail if Metal is missing or the renderer isn't
    /// created correctly. Otherwise, sets everything up.
    init?(view: GeneraMTLView) {
        let generator = BasicGenerator()
        guard let defaultDevice = MTLCreateSystemDefaultDevice(),
              let renderer = MapRenderer(view: view, device: defaultDevice, generatorDataDelegate: generator, generationDelegate: generator) else {
            assertionFailure("Game coordinator cannot be initialized")
            return nil
        }
        
        self.renderer = renderer
        self.generator = generator
        
        // Link viewport coordinator with the delegates
        view.delegate = renderer
        view.viewportDelegate = viewportCoordinator
        renderer.viewportDataDelegate = viewportCoordinator
        renderer.viewportChangeDelegate = viewportCoordinator
        
        // Notify the renderer when the map gets updated
        viewportCoordinator.mapUpdateDelegate = renderer
        generator.mapUpdateDelegate = renderer
    }
}
