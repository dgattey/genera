//
//  GameViewController.swift
//  Genera
//
//  Created by Dylan Gattey on 10/28/20.
//

import Cocoa
import MetalKit

// Our macOS specific view controller
class GameViewController: NSViewController {

    private let generator = BasicGenerator()
    private let viewportCoordinator = ViewportCoordinator()
    
    private var pannableView: PannableMTKView?
    private var renderer: Renderer?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let pannableView = self.view as? PannableMTKView,
              let defaultDevice = MTLCreateSystemDefaultDevice() else {
            assertionFailure("Metal isn't set up correctly")
            return
        }
        self.pannableView = pannableView

        guard let renderer = Renderer(view: pannableView, device: defaultDevice, generator: generator) else {
            assertionFailure("Renderer cannot be initialized")
            return
        }
        self.renderer = renderer
        
        // Link all the delegates and coordinators
        pannableView.viewportUpdaterDelegate = viewportCoordinator
        renderer.viewportUpdaterDelegate = viewportCoordinator
        renderer.viewportDataDelegate = viewportCoordinator
        viewportCoordinator.renderNotifierDelegate = renderer
        pannableView.delegate = renderer
        generator.delegate = renderer
        
        // Kick off generation
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
