//
//  GameViewController.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import Cocoa

/// The game's view controller - owns the coordinator and kicks off the game itself
class GameViewController: NSViewController {
    
    /// Just a reference to the game view itself
    @IBOutlet var gameView: InteractableMTKView!
    
    /// Coordinates the whole game, will be created from `start`. Sets the data provider here via generics.
    private var coordinator: GameCoordinator<GridTileChunkDataProvider>?
    
    /// Debug delegate
    weak var debugDelegate: DebugDelegate?
    
    /// Starts the game by creating the coordinator (that's all we need to start the rest)
    func start() {
        coordinator = GameCoordinator(view: gameView, debugDelegate: debugDelegate)
    }
}
