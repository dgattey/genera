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
    private let viewportCoordinator: ViewportCoordinator
    private let renderer: MapRenderer
    
    // MARK: initialization
    
    /// Initialization will fail if Metal is missing or the renderer isn't
    /// created correctly. Otherwise, sets everything up.
    init?(view: GeneraMTLView) {
        let generator = BasicGenerator()
        guard let defaultDevice = MTLCreateSystemDefaultDevice(),
              let renderer = MapRenderer(view: view, device: defaultDevice, generatorDataDelegate: generator) else {
            assertionFailure("Game coordinator cannot be initialized")
            return nil
        }
        
        self.renderer = renderer
        self.generator = generator
        self.viewportCoordinator = ViewportCoordinator(initialSize: view.drawableSize)
        
        // Link viewport coordinator with the delegates
        view.delegate = renderer
        view.viewportDelegate = viewportCoordinator
        generator.viewportDataDelegate = viewportCoordinator
        renderer.viewportDataDelegate = viewportCoordinator
        renderer.viewportChangeDelegate = viewportCoordinator
        
        // Notify the renderer when the map gets updated
        generator.mapUpdateDelegate = renderer
        viewportCoordinator.mapUpdateDelegate = renderer
        viewportCoordinator.generationDelegate = generator
        
        // Resize the renderer's view to make sure we're ready before map generation
        renderer.mtkView(view, drawableSizeWillChange: view.drawableSize)

        // Start map generation to kick off the process!
        DispatchQueue.global(qos: .utility).async(execute: generator.startMapGeneration)
    }
}
