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
    private var mainView: MTKView?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let mainView = self.view as? MTKView,
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
        mainView.delegate = newRenderer
        generator.delegate = newRenderer
        
        // Kick off generation
        generator.generateChunk(Chunk(x: 0, y: 0))
    }
}
