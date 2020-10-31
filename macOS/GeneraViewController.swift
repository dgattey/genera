//
//  GeneraViewController.swift
//  Genera
//
//  Created by Dylan Gattey on 10/28/20.
//

import Cocoa

// Our macOS specific view controller
class GeneraViewController: NSViewController {
    
    private var coordinator: GameCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let pannableView = self.view as? PannableMTKView else {
            assertionFailure("Configuration of app is wrong")
            return
        }
        
        // Creates the game coordinator and sets it up
        self.coordinator = GameCoordinator(view: pannableView)
        
    }
}
