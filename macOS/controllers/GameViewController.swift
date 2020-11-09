//
//  GameViewController.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import AppKit

/// The game's view controller - owns the coordinator and kicks off the game itself
class GameViewController: NSViewController {
    
    // MARK: - game types

    typealias ChunkDataProviderType = TerrainChunkDataProvider
    
    // MARK: - everything else
    
    /// Minimum window width
    private static let minWidth: CGFloat = 250
    
    /// Just a reference to the game view itself
    @IBOutlet var gameView: InteractableMTKView!
    
    /// Coordinates the whole game, will be created from `start`. Sets the data provider here via generics.
    private var coordinator: GameCoordinator<ChunkDataProviderType>?
    
    /// Debug delegate passthrough
    weak var debugDelegate: DebugDelegate? {
        didSet {
            coordinator?.debugDelegate = debugDelegate
        }
    }
    
    /// Shader config data provider passthrough
    weak var gameControllerDelegate: GameControllerDelegate?
    
    /// Starts the game by creating the coordinator, then kicking it off
    func start() {
        guard let coordinator = GameCoordinator<ChunkDataProviderType>(view: gameView) else {
            assertionFailure("Coordinator failed to set up")
            return
        }
        self.coordinator = coordinator
        
        // Create the config view too if it exists
        gameControllerDelegate?.gameController(hasNewDataProvider: coordinator.shaderDataProvider)
        
        // Set up the right data and start the coordination
        coordinator.debugDelegate = debugDelegate
        coordinator.start()
    }
    
    override func viewDidLoad() {
        self.view.widthAnchor.constraint(greaterThanOrEqualToConstant: GameViewController.minWidth).isActive = true
    }
}

/// Passes through to the coordinator
extension GameViewController: ConfigUpdateDelegate {
    
    /// Called when a value changes to another value
    func configDidUpdate<T>(from: T?, to: T?) {
        coordinator?.configDidUpdate(from: from, to: to)
    }
    
}
