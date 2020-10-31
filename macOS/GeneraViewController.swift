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

    /// Ensures we have the right views and sets up a game coordinator on view load.
    /// This is set up originally in the Main storyboard
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let generaView = self.view as? GeneraMTLView else {
            assertionFailure("App views are setup incorrectly: \(view)")
            return
        }
        self.coordinator = GameCoordinator(view: generaView)
        
    }
}
