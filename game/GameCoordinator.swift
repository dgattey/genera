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
    
    private let generator: GeneratorProtocol
    private let viewportCoordinator = ViewportCoordinator()
    private let renderer: Renderer
    
    // MARK: initialization
    
    /**
     Initialization will fail if Metal is missing or the renderer isn't
     created correctly. Otherwise, sets everything up
     */
    init?(view: PannableMTKView) {
        let generator = BasicGenerator()
        guard let defaultDevice = MTLCreateSystemDefaultDevice(),
              let renderer = Renderer(view: view, device: defaultDevice, generator: generator) else {
            assertionFailure("Game coordinator cannot be initialized")
            return nil
        }
        
        // Link all the delegates and coordinators and such
        view.delegate = renderer
        view.viewportDelegate = viewportCoordinator
        renderer.viewportDataDelegate = viewportCoordinator
        renderer.viewportUpdaterDelegate = viewportCoordinator
        viewportCoordinator.renderNotifierDelegate = renderer
        generator.delegate = renderer
        
        // Save the vars
        self.renderer = renderer
        self.generator = generator
        
        // FOR NOW - kick off generation manually
        for x in (0..<10) {
            for y in (0..<10) {
                generator.generateChunk(Chunk(x: x, y: y))
            }
        }
        for x in (-10..<0) {
            for y in (-10..<0) {
                generator.generateChunk(Chunk(x: x, y: y))
            }
        }
    }
}
