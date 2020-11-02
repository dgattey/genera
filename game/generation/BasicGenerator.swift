//
//  BasicGenerator.swift
//  Genera
//
//  Created by Dylan Gattey on 10/29/20.
//

import Metal
import simd
import Combine
import SwiftPriorityQueue

/// Just generates a totally random map
class BasicGenerator: NSObject, GeneratorDataDelegate {
    
    // MARK: constants
    
    /// The length of the event loops where we process evictions + generate
    private static let eventLoopInterval: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(1)
    
    // MARK: variables
    
    /// Basic dict of chunk -> array of tiles
    private var chunks = Dictionary<Chunk, [Tile]>()
    
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
    
    /// Used to update the map itself when generation of a chunk is done
    weak var mapUpdateDelegate: MapUpdateDelegate?
    
    /// Used to find out what's visible
    weak var viewportDataDelegate: ViewportDataDelegate?
    
    /// For debug printing
    weak var debugDelegate: DebugDelegate?
    
    /// Makes sure only one thing can access the chunks array at once
    private let chunkAccessSemaphore = DispatchSemaphore(value: 1)
    
    /// Makes sure only one thing can access the generation data structures at once
    private let generationAccessSemaphore = DispatchSemaphore(value: 1)
    
    /// Gets all visible chunks and pads it by our constant
    private var paddedVisibleRanges: (x: Range<Int>, y: Range<Int>) {
        guard let ranges = viewportDataDelegate?.visibleChunks else {
            assertionFailure("No visible chunks to use (shouldn't be possible)")
            return ((0..<0), (0..<0))
        }
        return ranges
    }

    /// The amount of chunks in memory we allow (based on viewport size)
    private var maxChunksInMemory: Int {
        return paddedVisibleRanges.x.count * paddedVisibleRanges.y.count
    }
    
    // MARK: - GeneratorDataDelegate
    
    /// Returns vertices for a particular chunk of data if it exists, or nil (and marks it as recently accessed for use in eviction)
    func vertices(for chunk: Chunk) -> [Float] {
        chunkAccessSemaphore.wait()
        unsafelyMarkChunkAsRecentlyAccessed(chunk)
        
        // Get the tiles if they exist
        guard let tiles = chunks[chunk] else {
            chunkAccessSemaphore.signal()
            return []
        }
        chunkAccessSemaphore.signal()
        let tileWidth = Float(Size.tileWidthInPixels)
        return tiles.flatMap { tile in
            return tile.vertices.map { vertex in
                return vertex * tileWidth
            }
        }
    }
    
    /// Returns colors for a particular chunk of data if it exists, or nil
    func colors(for chunk: Chunk) -> [Float] {
        chunkAccessSemaphore.wait()
        guard let tiles = chunks[chunk] else {
            chunkAccessSemaphore.signal()
            return []
        }
        chunkAccessSemaphore.signal()
        return tiles.flatMap { tile in
            return tile.colors.map { colorValue in
                return colorValue
            }
        }
    }
    
    // MARK: - helper functions
    
    /// Generates the tiles for the next queued chunk, then notifies on the main thread. MUST be called for speed from a background
    /// thread, ideally an event loop.
    private func generateClosestTile() {
        generationAccessSemaphore.wait()
        guard let chunk = needsGenerationQueue.pop() else {
            generationAccessSemaphore.signal()
            // Reached the end of the queue!
            generationEventLoop?.cancel()
            generationEventLoop = nil
            return
        }
        Logger.log("*** Generating! \(chunk)")
        let needsGenerationCount = needsGenerationQueue.count
        let inProgressCount = inProgressGenerationQueue.count
        generationAccessSemaphore.signal()
        
        // Ensure our chunk is within our visible range, otherwise just discard
        guard chunk.value.isWithin(paddedVisibleRanges) else {
            debugDelegate?.didUpdateGenerationQueue(to: (needsGenerationCount, inProgressCount))
            return
        }
        
        // Make sure we haven't already generated this!
        chunkAccessSemaphore.wait()
        guard !chunks.keys.contains(chunk.value) else {
            debugDelegate?.didUpdateGenerationQueue(to: (needsGenerationCount, inProgressCount))
            chunkAccessSemaphore.signal()
            return
        }
        chunkAccessSemaphore.signal()
        
        
        // Add it to our in progress queue and drop the semaphore
        generationAccessSemaphore.wait()
        inProgressGenerationQueue.insert(chunk.value)
        debugDelegate?.didUpdateGenerationQueue(to: (needsGenerationQueue.count, inProgressGenerationQueue.count))
        generationAccessSemaphore.signal()
        
        // Do hard work of generating!
        let tiles = (0 ..< Size.chunk).flatMap { x -> [Tile] in
            return (0 ..< Size.chunk).map { y -> Tile in
                let tileX = x + chunk.value.x * Size.chunk
                let tileY = y + chunk.value.y * Size.chunk
                let randomRawTileKind = Int.random(in: (0 ..< Tile.Kind.total))
                let kind = Tile.Kind(rawValue: randomRawTileKind) ?? .water
                return Tile(x: tileX, y: tileY, kind: kind)
            }
        }
        
        // Update the chunks array with the tiles and remove from in generation queue
        chunkAccessSemaphore.wait()
        chunks[chunk.value] = tiles
        debugDelegate?.didUpdateNumGeneratedChunks(to: chunks.count)
        chunkAccessSemaphore.signal()
        
        generationAccessSemaphore.wait()
        inProgressGenerationQueue.remove(chunk.value)
        debugDelegate?.didUpdateGenerationQueue(to: (needsGenerationQueue.count, inProgressGenerationQueue.count))
        generationAccessSemaphore.signal()
        
        DispatchQueue.main.async { [weak self] in
            self?.mapUpdateDelegate?.didGenerate(chunk: chunk.value)
        }
    }
    
    /// Marks a chunk as recently accessed with semaphore. Use `unsafelyMarkChunkAsRecentlyAccessed` if you're already waiting
    /// on`chunkAccessSemaphore`.
    private func markChunkAsRecentlyAccessed(_ chunk: Chunk) {
        chunkAccessSemaphore.wait()
        unsafelyMarkChunkAsRecentlyAccessed(chunk)
        chunkAccessSemaphore.signal()
    }
    
    /// Marks a chunk as recently accessed. Should be used in a context where you're already waiting on the
    /// `chunkAccessSemaphore`, otherwise it's unsafe. There's an analogous `markChunkAsRecentlyAccessed` if
    /// you need the locking done for you.
    private func unsafelyMarkChunkAsRecentlyAccessed(_ chunk: Chunk) {
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
        let recentCount = recentlyAccessedChunks.count
        
        // Stop if nothing to evict
        guard let evictableChunk = leastRecentChunk else {
            chunkAccessSemaphore.signal()
            Logger.log("~Evict~ finished evicting")
            return
        }
        
        // If it's within the visible range, mark as accessed recently (and the element will move
        // so the next iteration of this eviction loop should get a different element)
        guard !evictableChunk.value.isWithin(paddedVisibleRanges) else {
            Logger.log("~Evict~ in viewport \(evictableChunk) (recent count: \(recentCount))")
            unsafelyMarkChunkAsRecentlyAccessed(evictableChunk.value)
            chunkAccessSemaphore.signal()
            return
        }
        
        // Evict the chunk itself!
        let oldTiles = chunks.removeValue(forKey: evictableChunk.value)
        Logger.log("~Evict~ removed a chunk: \(evictableChunk.value) to leave \(chunks.count) in \(paddedVisibleRanges)")
        debugDelegate?.didUpdateNumGeneratedChunks(to: chunks.count)
        chunkAccessSemaphore.signal()
        
        // Only notify if we actually removed something (as we may have already removed this guy)
        if (oldTiles != nil) {
            DispatchQueue.main.async { [weak self] in
                self?.mapUpdateDelegate?.didDelete(chunk: evictableChunk.value)
            }
        }
        
    }
    
    /// This starts the loop of evicting chunks on a background thread if not started
    private func evictChunksIfNeeded(outside ranges: (x: Range<Int>, y: Range<Int>)) {
        guard evictionEventLoop == nil else {
            return
        }
        
        // We have too many chunks - let's evict until we have nothing new to evict
        evictionEventLoop = DispatchQueue.global(qos: .userInteractive).schedule(
            after: DispatchQueue.SchedulerTimeType(.now()),
            interval: BasicGenerator.eventLoopInterval,
            evictOldestChunk)
    }
    
}

// MARK: - GenerationDelegate

extension BasicGenerator: GeneratorProtocol {
    
    /// Just generates visible chunks to start with
    func startMapGeneration() {
        guard let ranges = viewportDataDelegate?.visibleChunks else {
            assertionFailure("No chunks visible at start of map generation")
            return
        }
        didUpdateVisibleChunks(ranges)
    }
    
    /// Asynchronously generates a chunk of data and notifies our delegate on
    /// the main thread when done. All generation is async and random.
    func generateChunkIfNeeded(_ chunk: Chunk) {
        // Make sure this chunk's in bounds
        guard chunk.isWithin(paddedVisibleRanges) else {
            return
        }
        
        // Make sure we haven't already generated this one
        chunkAccessSemaphore.wait()
        if chunks.keys.contains(chunk) {
            chunkAccessSemaphore.signal()
            return
        }
        chunkAccessSemaphore.signal()
        
        // Make sure we're not actively generating!
        generationAccessSemaphore.wait()
        if inProgressGenerationQueue.contains(chunk) {
            generationAccessSemaphore.signal()
            return
        }
        
        // If it's already in our needs generation queue OR not, push an incremented count. This will
        // duplicate the object in the first case, but the higher value should ensure we process it first
        let incremented = viewportDataDelegate?.distanceToUserPositionSquared(fromChunk: chunk)
        let countedChunk = CountedChunk(chunk, count: Int(incremented ?? 1))
        // TODO: @dgattey the problem with this count always being 1 si that I don't use the value I REMOVE because it doesn't return (and it's O(n)). Maybe
        // I need something other than just a priority queue...
        needsGenerationQueue.remove(countedChunk)
        needsGenerationQueue.push(countedChunk)
        Logger.log("~~~ Queued generation of \(countedChunk)")
        debugDelegate?.didUpdateGenerationQueue(to: (needsGenerationQueue.count, inProgressGenerationQueue.count))
        generationAccessSemaphore.signal()
        
        // Make sure our event loop is running!
        if (generationEventLoop == nil) {
            generationEventLoop = DispatchQueue.global(qos: .userInteractive).schedule(
                after: DispatchQueue.SchedulerTimeType(.now()),
                interval: BasicGenerator.eventLoopInterval,
                generateClosestTile)
        }
    }
    
    /// Makes sure these chunks are currently generated, and evict chunks if they're outside our bounds and we're at the limit
    func didUpdateVisibleChunks(_ ranges: (x: Range<Int>, y: Range<Int>)) {
        evictChunksIfNeeded(outside: ranges)
        for x in ranges.x {
            for y in ranges.y {
                generateChunkIfNeeded(Chunk(x: x, y: y))
            }
        }
        debugDelegate?.didUpdateChunkBounds(to: ranges)
    }
    
}
