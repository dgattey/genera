//
//  GeneraWindowController.swift
//  Genera
//
//  Created by Dylan Gattey on 11/1/20.
//

import Cocoa
import MetalKit

/// Coordinates the game through references to the views
class GeneraWindowController: NSWindowController {
    
    /// Coordinates the whole game, will be created in `windowDidLoad`
    private var coordinator: GameCoordinator?
    
    /// Sets up whole app, using the next run loop to make sure the window has resized at least once
    override func windowDidLoad() {
        super.windowDidLoad()
        DispatchQueue.main.async {
            self.window?.toolbar?.insertItem(withItemIdentifier: .flexibleSpace, at: 0)
            self.window?.toolbar?.insertItem(withItemIdentifier: .toggleSidebar, at: 1)
            self.setupGameCoordinator()
        }
    }
    
    /// Creates the game coordinator itself using the views in our given window
    private func setupGameCoordinator() {
        guard let view = window?.contentView,
              let gameView = GeneraWindowController.viewOfType(InteractableMTKView.self, using: view),
              let debugView = GeneraWindowController.viewOfType(GeneraDebugView.self, using: view) else {
            assertionFailure("Views incorrectly configured, please check the storyboard!")
            return
        }
        coordinator = GameCoordinator(view: gameView, debugView: debugView)
    }
    
    /// Finds (recursively) a view matching a type in the window hierarchy. Used to get around me not knowing how to get
    /// a reference to a deeply nested view from the storyboard
    private static func viewOfType<T: NSView>(_ viewType: T.Type, using view: NSView) -> T? {
        if type(of: view) == viewType {
            return view as? T
        }
        for subview in view.subviews {
            if let foundView = viewOfType(viewType, using: subview) {
                return foundView
            }
        }
        return nil
    }
}
