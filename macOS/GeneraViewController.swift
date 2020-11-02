//
//  GeneraViewController.swift
//  Genera
//
//  Created by Dylan Gattey on 10/28/20.
//

import Cocoa

/// Our macOS specific view controller - starts coordination of the game
class GeneraViewController: NSViewController {
    
    private var coordinator: GameCoordinator?
    @IBOutlet var gameView: InteractableMTKView!
    @IBOutlet var debugView: GeneraDebugView?

    /// Ensures we have the right views and sets up a game coordinator on view load.
    /// This is set up originally in the Main storyboard
    override func viewDidLoad() {
        // Putting it on the next run loop means the window will be correctly sized for the view to lay out
        DispatchQueue.main.async {
            self.coordinator = GameCoordinator(view: self.gameView, debugView: self.debugView)
        }
    }
}
