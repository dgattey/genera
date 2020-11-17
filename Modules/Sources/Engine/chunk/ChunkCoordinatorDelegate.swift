// ChunkCoordinatorDelegate.swift
// Copyright (c) 2020 Dylan Gattey

import DataStructuresSwift
import Foundation

/// A delegate for use with all map updates that need to be processed by the renderer
protocol ChunkCoordinatorDelegate: NSObject {
    /// Called when a chunk has updated tiles to use
    func chunkCoordinator(didGenerate chunk: Chunk) -> Void

    /// Called when a chunk's tiles should be deleted
    func chunkCoordinator(didDelete chunk: Chunk) -> Void
}
