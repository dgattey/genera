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
    typealias ShaderDataProviderType = TerrainConfigView
    
    // MARK: - everything else
    
    /// Minimum window width
    private static let minWidth: CGFloat = 250
    
    /// Just a reference to the game view itself
    @IBOutlet var gameView: InteractableMTKView!
    
    /// Coordinates the whole game, will be created from `start`. Sets the data provider here via generics.
    private var coordinator: GameCoordinator<ChunkDataProviderType, ShaderDataProviderType>?
    
    /// Debug delegate passthrough
    weak var debugDelegate: DebugDelegate? {
        didSet {
            coordinator?.debugDelegate = debugDelegate
        }
    }
    
    /// Shader config data provider passthrough
    weak var shaderConfigDataProvider: ShaderDataProviderType? {
        didSet {
            coordinator?.shaderDataProvider = shaderConfigDataProvider
        }
    }
    
    /// Starts the game by creating the coordinator, then kicking it off
    func start() {
        guard let coordinator = GameCoordinator<ChunkDataProviderType, ShaderDataProviderType>(view: gameView) else {
            assertionFailure("Coordinator failed to set up")
            return
        }
        self.coordinator = coordinator
        
        // Set up the right data and start the coordination
        coordinator.debugDelegate = debugDelegate
        coordinator.shaderDataProvider = shaderConfigDataProvider
        coordinator.start()
    }
    
    override func viewDidLoad() {
        self.view.widthAnchor.constraint(greaterThanOrEqualToConstant: GameViewController.minWidth).isActive = true
    }
}

extension GameViewController: TerrainConfigUpdateDelegate {
    
    func configDidUpdate() {
        coordinator?.configDidUpdate()
    }
    
}
