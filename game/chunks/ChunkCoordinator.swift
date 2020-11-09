//
//  RandomTileGenerator.swift
//  Genera
//
//  Created by Dylan Gattey on 10/29/20.
//

import Metal
import simd
import Combine
import SwiftPriorityQueue

/// Constants for the map generator
private enum ChunkCoordinatorConstant {
    
    /// The length of the event loops where we process evictions + generate
    static let eventLoopInterval: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(1)
}

/// Generic class for generating a map. Parameterized with a type of data to use
class ChunkCoordinator<DataProvider: ChunkDataProviderProtocol>: NSObject {
    
    // MARK: - variables
    
    /// Basic dict of chunk -> array of ChunkData
    private var chunks = Dictionary<Chunk, [DataProvider.ChunkDataType]>()
    
    /// Keeps track of the order we added chunks for smarter removal (pop the top)
    private var recentlyAccessedChunks = PriorityQueue<DatedChunk>(ascending: true)
    
    /// Makes sure we only ever have one event loop running for evictions (no sense in
    /// making this happen multiple times)
    private var evictionEventLoop: Cancellable?
    
    /// Makes sure we only ever have one event loop running for generation
    private var generationEventLoop: Cancellable?
    
    /// The chunks we need to generate based on their request count (only generates chunks within visible bounds)
    private var needsGenerationQueue = PriorityQueue<CountedChunk>(ascending: true)
    
    /// The chunks we're currently generating (count doesn't matter)
    private var inProgressGenerationQueue = Set<Chunk>()
    
    /// Used to find out what's visible
    weak var viewportDataProvider: ViewportDataProvider?
    
    /// Used to update the delegate with new chunk info
    weak var chunkCoordinatorDelegate: ChunkCoordinatorDelegate?
    
    /// For debug printing
    weak var debugDelegate: DebugDelegate?
    
    /// Makes sure only one thing can access the chunks array at once
    private let chunkAccessSemaphore = DispatchSemaphore(value: 1)
    
    /// Makes sure only one thing can access the generation data structures at once
    private let generationAccessSemaphore = DispatchSemaphore(value: 1)
    
    /// Weakly held data provider for querying
    private weak var dataProvider: DataProvider?
    
    /// Gets all visible chunks and pads it by our constant
    private var visibleRegion: ChunkRegion {
        guard let region = viewportDataProvider?.visibleRegion else {
            assertionFailure("No visible chunks to use (shouldn't be possible)")
            return ((0..<0), (0..<0))
        }
        return region
    }
    
    /// Used to block async tasks from starting once we shut down
    private var shouldCoordinate = true
    
    /// Saves the generation function for use later
    init(dataProvider: DataProvider?) {
        self.dataProvider = dataProvider
    }
    
    /// Called when we need to shut down this coordinator
    func shutdown() {
        shouldCoordinate = false
        evictionEventLoop?.cancel()
        generationEventLoop?.cancel()
    }
    
    // MARK: - chunk data manipulation
    
    /// Safely checks if chunk data contains a given chunk
    private func chunkData(contains chunk: Chunk) -> Bool {
        chunkAccessSemaphore.wait()
        defer {
            chunkAccessSemaphore.signal()
        }
        return chunks.keys.contains(chunk)
    }
    
    /// Returns data for a chunk, locking around it
    private func chunkData(for chunk: Chunk) -> [DataProvider.ChunkDataType] {
        chunkAccessSemaphore.wait()
        defer {
            chunkAccessSemaphore.signal()
        }
        markChunkAsRecentlyAccessed(chunk)
        return chunks[chunk] ?? []
    }
    
    /// Sets data for a chunk, locking around it
    private func setChunkData(for chunk: Chunk, to data: [DataProvider.ChunkDataType]) {
        chunkAccessSemaphore.wait()
        chunks[chunk] = data
        debugDelegate?.didUpdateNumGeneratedChunks(to: chunks.count)
        chunkAccessSemaphore.signal()
    }
    
    // MARK: - functions called outside this file
    
    /// Returns vertices for a particular chunk of data if they exist to the renderer
    func vertices(from chunk: Chunk) -> [DataProvider.ChunkDataType.VertexType] {
        return chunkData(for: chunk).flatMap { $0.vertices }
    }
    
    /// Just generates visible chunks to start with
    func startMapGeneration() {
        guard shouldCoordinate else {
            return
        }
        guard let region = viewportDataProvider?.visibleRegion else {
            assertionFailure("No chunks visible at start of map generation")
            return
        }
        handle(updatedVisibleRegion: region)
    }
    
    /// Makes sure these chunks are currently generated, and evict chunks if they're outside our bounds and we're at the limit
    func handle(updatedVisibleRegion region: ChunkRegion) {
        guard shouldCoordinate else {
            return
        }
        evictChunksIfNeeded()
        for x in region.x {
            for y in region.y {
                generateChunkIfNeeded(Chunk(x: x, y: y))
            }
        }
        debugDelegate?.didUpdateChunkBounds(to: region)
    }
    
    // MARK: - helper functions
    
    /// Generates the tiles for the next queued chunk, then notifies on the main thread. MUST be called for speed from a background
    /// thread, ideally an event loop.
    private func generateClosestChunk() {
        generationAccessSemaphore.wait()
        guard let chunk = needsGenerationQueue.pop() else {
            generationAccessSemaphore.signal()
            // Reached the end of the queue!
            generationEventLoop?.cancel()
            generationEventLoop = nil
            return
        }
        let needsGenerationCount = needsGenerationQueue.count
        let inProgressCount = inProgressGenerationQueue.count
        generationAccessSemaphore.signal()
        
        // Ensure our chunk is within our visible range, and ungenerated
        guard chunk.value.isWithin(visibleRegion),
              !chunkData(contains: chunk.value) else {
            debugDelegate?.didUpdateGenerationQueue(to: (needsGenerationCount, inProgressCount))
            return
        }
        
        // Add it to our in progress queue and drop the semaphore
        generationAccessSemaphore.wait()
        inProgressGenerationQueue.insert(chunk.value)
        debugDelegate?.didUpdateGenerationQueue(to: (needsGenerationQueue.count, inProgressGenerationQueue.count))
        Logger.log("*** Generating! \(chunk)")
        generationAccessSemaphore.signal()
        
        // Update the chunks array with the tiles and remove from in generation queue
        guard let data = dataProvider?.generateChunkData(for: chunk.value) else {
            assertionFailure("Missing data provider")
            return
        }
        setChunkData(for: chunk.value, to: data)
        
        generationAccessSemaphore.wait()
        inProgressGenerationQueue.remove(chunk.value)
        debugDelegate?.didUpdateGenerationQueue(to: (needsGenerationQueue.count, inProgressGenerationQueue.count))
        generationAccessSemaphore.signal()
        
        DispatchQueue.main.async { [weak self] in
            self?.chunkCoordinatorDelegate?.chunkCoordinator(didGenerate: chunk.value)
        }
    }
    
    /// Marks a chunk as recently accessed. Should be used in a context where you're already waiting on the
    /// `chunkAccessSemaphore`, otherwise it's unsafe.
    private func markChunkAsRecentlyAccessed(_ chunk: Chunk) {
        let datedChunk = DatedChunk(chunk)
        // This only works because hashing and equatable use the chunk itself, not the date
        if recentlyAccessedChunks.peek() == datedChunk {
            // Perf improvement if it was the first element
            _ = recentlyAccessedChunks.pop()
        } else if recentlyAccessedChunks.contains(datedChunk) {
            recentlyAccessedChunks.remove(datedChunk)
            Logger.log("+++ replacing \(datedChunk)")
        }
        // Replace whatever was there with newly-dated data
        recentlyAccessedChunks.push(datedChunk)
    }
    
    /// Evicts one chunk at a time, assuming this is called on a loop from a background
    /// thread for performance reasons. Cancels the loop if we have nothing new to evict.
    private func evictOldestChunk() {
        chunkAccessSemaphore.wait()
        let leastRecentChunk = recentlyAccessedChunks.pop()
        
        // Stop if nothing to evict
        guard let evictableChunk = leastRecentChunk else {
            chunkAccessSemaphore.signal()
            return
        }
        
        // If it's within the visible range, mark as accessed recently (and the element will move
        // so the next iteration of this eviction loop should get a different element)
        guard !evictableChunk.value.isWithin(visibleRegion) else {
            markChunkAsRecentlyAccessed(evictableChunk.value)
            chunkAccessSemaphore.signal()
            return
        }
        
        // Evict the chunk itself!
        let oldData = chunks.removeValue(forKey: evictableChunk.value)
        debugDelegate?.didUpdateNumGeneratedChunks(to: chunks.count)
        chunkAccessSemaphore.signal()
        
        // Only notify if we actually removed something (as we may have already removed this guy)
        if (oldData != nil) {
            DispatchQueue.main.async { [weak self] in
                self?.chunkCoordinatorDelegate?.chunkCoordinator(didDelete: evictableChunk.value)
            }
        }
        
    }
    
    /// This starts the loop of evicting chunks on a background thread if not started
    private func evictChunksIfNeeded() {
        guard evictionEventLoop == nil else {
            return
        }
        
        // We have too many chunks - let's evict until we have nothing new to evict
        evictionEventLoop = DispatchQueue.global(qos: .userInteractive).schedule(
            after: DispatchQueue.SchedulerTimeType(.now()),
            interval: ChunkCoordinatorConstant.eventLoopInterval,
            evictOldestChunk)
    }
    
    /// Asynchronously generates a chunk of data and notifies our delegate on
    /// the main thread when done. All generation is async and random.
    func generateChunkIfNeeded(_ chunk: Chunk) {
        // Make sure this chunk's in bounds
        guard chunk.isWithin(visibleRegion) else {
            return
        }
        
        // Make sure we haven't already generated this one
        if chunkData(contains: chunk) {
            return
        }
        
        // Make sure we're not actively generating!
        generationAccessSemaphore.wait()
        if inProgressGenerationQueue.contains(chunk) {
            generationAccessSemaphore.signal()
            return
        }
        
        // If it's already in our needs generation queue OR not, push an incremented count. This will
        // duplicate the object in the first case, but the higher value should ensure we process it first
        let incremented = viewportDataProvider?.distanceToUserPositionSquared(fromChunk: chunk)
        let countedChunk = CountedChunk(chunk, count: Int(incremented ?? 1))
        needsGenerationQueue.remove(countedChunk)
        needsGenerationQueue.push(countedChunk)
        Logger.log("~~~ Queued generation of \(countedChunk)")
        debugDelegate?.didUpdateGenerationQueue(to: (needsGenerationQueue.count, inProgressGenerationQueue.count))
        generationAccessSemaphore.signal()
        
        // Make sure our event loop is running!
        if (generationEventLoop == nil) {
            generationEventLoop = DispatchQueue.global(qos: .userInitiated).schedule(
                after: DispatchQueue.SchedulerTimeType(.now()),
                interval: ChunkCoordinatorConstant.eventLoopInterval,
                generateClosestChunk)
        }
    }
    
}
