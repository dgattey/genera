// RendererAction.swift
// Copyright (c) 2020 Dylan Gattey

import Foundation
import Metal

/// All possible actions the renderer has to respond to
enum RendererAction {
    /// Evicts one chunk from the list of existing chunks
    case evictChunk(Chunk)

    /// Generates one chunk in the list of existing chunks
    case generateChunk(Chunk)

    /// Updates the user position to a new position in a drawable size
    case updateUserPosition(to: MTLViewport, inDrawableSize: CGSize)

    /// Updates the visible region to a new chunk region
    case updateVisibleRegion(to: ChunkRegion)

    /// Just redraws whatever's in range
    case redrawMap
}
