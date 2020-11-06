//
//  GeneraWindowController.swift
//  Genera
//
//  Created by Dylan Gattey on 11/1/20.
//

import Cocoa
import MetalKit

/// Owns the views in the app and starts the game controller after an event loop on app start
class GeneraWindowController: NSWindowController {
    
    /// Sets up whole app, using the next run loop to make sure the window has resized at least once before creating the coordinator
    override func windowDidLoad() {
        super.windowDidLoad()
        guard let contentViewController = window?.contentViewController,
              let gameViewController: GameViewController = firstViewController(in: contentViewController),
              let sidePanelViewController: SidePanelViewController = firstViewController(in: contentViewController) else {
            assertionFailure("Views incorrectly set up")
            return
        }
        
        gameViewController.debugDelegate = sidePanelViewController.debugView
        
        DispatchQueue.main.async {
            self.window?.toolbar?.insertItem(withItemIdentifier: .flexibleSpace, at: 0)
            self.window?.toolbar?.insertItem(withItemIdentifier: .toggleSidebar, at: 1)
            gameViewController.start()
        }
    }
    
    /// Finds the first view controller of a certain type in the given view controller to get around Storyboards being absolute shit
    func firstViewController<T: NSViewController>(in parentController: NSViewController) -> T? {
        for viewController in parentController.children {
            if let match = viewController as? T {
                return match
            }
            if let subChild: T = firstViewController(in: viewController) {
                return subChild
            }
        }
        
        return nil
    }
    
}
