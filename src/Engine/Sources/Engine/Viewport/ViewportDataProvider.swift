// ViewportDataProvider.swift
// Copyright (c) 2020 Dylan Gattey

import EngineCore
import Metal

/// Returns viewport data to other objects
protocol ViewportDataProvider: NSObject {
    /// The current viewport to render within (should always have origin at 0,0)
    var currentViewport: MTLViewport { get }

    /// A way to get the region of visible chunks onscreen x and y
    var visibleRegion: ChunkRegion { get }

    /// Returns the absolute distance squared from a chunk to the user position. Squared for
    /// speed because division is slow.
    func distanceToUserPositionSquared(fromChunk chunk: Chunk) -> Float
}
