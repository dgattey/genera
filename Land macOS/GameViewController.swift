//
//  GameViewController.swift
//  Land macOS
//
//  Created by Dylan Gattey on 10/28/20.
//

import Cocoa
import MetalKit

// Our macOS specific view controller
class GameViewController: NSViewController {

    var renderer: Renderer?
    var mainView: MTKView?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let mainView = self.view as? MTKView,
              let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal isn't set up correctly")
            return
        }

        guard let newRenderer = Renderer(view: mainView, device: defaultDevice) else {
            print("Renderer cannot be initialized")
            return
        }
        // Set the size once to kick off initial drawing process
        newRenderer.mtkView(mainView, drawableSizeWillChange: mainView.drawableSize)
        
        // Make sure the view's delegate is our new renderer, and save it
        mainView.delegate = newRenderer
        renderer = newRenderer
    }
}
