// DebugDelegate.swift
// Copyright (c) 2020 Dylan Gattey

import Foundation
import MetalKit

/// Anything that shows debug data implements this
protocol DebugDelegate: NSObject {
    /// Called when chunk bounds update
    func didUpdateChunkBounds(to value: ChunkRegion) -> Void

    /// Called when number of generated chunks updates
    func didUpdateNumGeneratedChunks(to value: Int) -> Void

    /// Called when the generation queue changes
    func didUpdateGenerationQueue(to value: (needsGeneration: Int, inProgress: Int))

    /// Called when user position in the viewport changes
    func didUpdateUserPosition(to value: MTLViewport) -> Void

    /// Called when the current viewport itself changes
    func didUpdateCurrentViewport(to value: MTLViewport) -> Void
}
