// GameViewController.swift
// Copyright (c) 2020 Dylan Gattey

import AppKit

/// All constants for the generic game view controller
enum GameViewControllerConstant {
    /// Minimum window width
    static let minWidth: CGFloat = 250
}

/// The game's view controller - owns the coordinator and kicks off the game itself
class GameViewController: NSViewController {
    /// Just a reference to the game view itself
    @IBOutlet var gameView: InteractableMTKView!

    /// Check `gameType` to verify what type of `GameCoordinator<T>` this should be! Unfortunately doesn't allow for
    /// a more specific use since `GameCoordinator<T>` is a generic with an associated type within it - super difficult
    private var coordinator: Any?

    /// Specializes the coordinator to terrain provider
    var terrainCoordinator: GameCoordinator<TerrainChunkDataProvider>? {
        coordinator as? GameCoordinator<TerrainChunkDataProvider>
    }

    /// Specializes the coordinator to grid provider
    var gridCoordinator: GameCoordinator<GridTileChunkDataProvider>? {
        coordinator as? GameCoordinator<GridTileChunkDataProvider>
    }

    /// Controls which coordinator we use!
    private var gameType: GameType = .terrain

    /// Debug delegate passthrough
    weak var debugDelegate: DebugDelegate? {
        didSet {
            updateDebugDelegates()
        }
    }

    /// Shader config data provider passthrough
    weak var gameControllerDelegate: GameControllerDelegate?

    /// Starts the game by creating the coordinator, then kicking it off
    func reset(to gameType: GameType) {
        gameView.delegate = nil // reset in preparation
        self.gameType = gameType
        switch gameType {
        case .grid:
            guard let coordinator = GameCoordinator<GridTileChunkDataProvider>(view: gameView) else {
                fatalError("No coordinator created")
            }
            self.coordinator = coordinator
            gameControllerDelegate?.gameController(hasNewDataProvider: coordinator.shaderDataProvider)
            updateDebugDelegates()
            coordinator.start()
        case .terrain:
            guard let coordinator = GameCoordinator<TerrainChunkDataProvider>(view: gameView) else {
                fatalError("No coordinator created")
            }
            self.coordinator = coordinator
            gameControllerDelegate?.gameController(hasNewDataProvider: coordinator.shaderDataProvider)
            updateDebugDelegates()
            coordinator.start()
        }
    }

    override func viewDidLoad() {
        view.widthAnchor.constraint(greaterThanOrEqualToConstant: GameViewControllerConstant.minWidth).isActive = true
    }

    /// Calls right coordinator to set the debug delegate
    private func updateDebugDelegates() {
        switch gameType {
        case .terrain:
            terrainCoordinator?.debugDelegate = debugDelegate
        case .grid:
            gridCoordinator?.debugDelegate = debugDelegate
        }
    }
}

/// Passes through to the coordinator
extension GameViewController: ConfigUpdateDelegate {
    /// Called when a value changes to another value
    func configDidUpdate<T>(from: T?, to: T?) {
        switch gameType {
        case .terrain:
            terrainCoordinator?.configDidUpdate(from: from, to: to)
        case .grid:
            gridCoordinator?.configDidUpdate(from: from, to: to)
        }
    }
}
