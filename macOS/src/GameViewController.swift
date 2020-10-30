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
    private var renderer: Renderer?
    private var mainView: PannableMTKView?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let mainView = self.view as? PannableMTKView,
              let defaultDevice = MTLCreateSystemDefaultDevice() else {
            assertionFailure("Metal isn't set up correctly")
            return
        }

        guard let newRenderer = Renderer(view: mainView, device: defaultDevice, generator: generator) else {
            assertionFailure("Renderer cannot be initialized")
            return
        }
        renderer = newRenderer
        
        // Link up the renderer and generator
        mainView.viewportChangeDelegate = newRenderer
        mainView.delegate = newRenderer
        generator.delegate = newRenderer
        
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
