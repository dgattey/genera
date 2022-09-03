// ViewportCoordinator.swift
// Copyright (c) 2022 Dylan Gattey

import Combine
import Debug
import EngineCore
import Metal

/// Private static constants for the viewport coordinator
private enum ViewportCoordinatorConstant {
    /// The amount by which to translate in pixels when using keyboard or mouse
    static let translationStep: Double = 30

    /// The amount by which to translate on a diagonal in pixels when using keyboard
    /// or mouse, resulting in the same diagonal movement when applied to both the
    /// horizontal and the vertical translation
    static let diagonalTranslationStep: Double = translationStep * sin(45)

    // MARK: - types

    /// All zoom levels
    enum ZoomLevel {
        /// Minimum zoom supported
        static let min: Double = 0.2

        /// Max zoom supported
        static let max: Double = 1.4

        /// The multiplier on the zoom amount
        static let multiplier = 0.01
    }

    /// Pad by at least this amount of chunks in any direction
    static let minChunkPadAmount = 1
}

/// ViewportCoordinator functions for use with Metal manipulations
class ViewportCoordinator<DataProvider: ChunkDataProviderProtocol>: NSObject, ViewportDataProvider {
    // MARK: - static helpers

    /// Returns the absolute distance squared from a chunk to a pixel space point. Squared for
    /// speed because division is slow.
    private static func distanceSquared(fromChunk chunk: Chunk, toPixelSpacePoint point: (x: Double, y: Double),
                                        chunkSizeInPixels: Int) -> Float
    {
        let x1 = Float(chunk.x)
        let y1 = Float(chunk.y)
        let x2 = Float(convertToChunkSpace(point.x, chunkSizeInPixels: chunkSizeInPixels))
        let y2 = Float(convertToChunkSpace(point.y, chunkSizeInPixels: chunkSizeInPixels))
        return abs((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
    }

    /// Converts a value to chunk space (rounded up or down depending on which side of zero we're on)
    private static func convertToChunkSpace(_ value: Double, chunkSizeInPixels: Int) -> Int {
        Int(round(value / Double(chunkSizeInPixels)))
    }

    /// Converts the viewport passed to a rect of visible chunks (in whole chunk-units, with 10% padding or at least one chunk)
    /// on all sides.
    private static func visibleRegion(from viewport: MTLViewport, chunkSizeInPixels: Int) -> ChunkRegion {
        let startX = convertToChunkSpace(viewport.originX - viewport.width, chunkSizeInPixels: chunkSizeInPixels)
        let startY = convertToChunkSpace(viewport.originY - viewport.height, chunkSizeInPixels: chunkSizeInPixels)
        let endX = convertToChunkSpace(viewport.originX + viewport.width, chunkSizeInPixels: chunkSizeInPixels)
        let endY = convertToChunkSpace(viewport.originY + viewport.height, chunkSizeInPixels: chunkSizeInPixels)

        let pad: (Range<Int>) -> Range<Int> = { range in
            let distance: Int = Swift.max((range.endIndex - range.startIndex) / 3,
                                          ViewportCoordinatorConstant.minChunkPadAmount)
            return (range.startIndex - distance ..< range.endIndex + distance)
        }
        return (pad(startX ..< endX), pad(startY ..< endY))
    }

    /// Convenience function for resizing a viewport to another size
    private static func viewport(byResizing viewport: MTLViewport,
                                 to size: CGSize,
                                 atZoom zoomMultiplier: Double = 1.0) -> MTLViewport
    {
        MTLViewport(originX: viewport.originX,
                    originY: viewport.originY,
                    width: Double(size.width) * zoomMultiplier,
                    height: Double(size.height) * zoomMultiplier,
                    znear: viewport.znear,
                    zfar: viewport.zfar)
    }

    /// Convenience function for translating a viewport to another location
    private static func viewport(byTranslating viewport: MTLViewport,
                                 in directions: Set<VectoredDirection<Double>>,
                                 atZoom zoomMultiplier: Double = 1.0) -> MTLViewport
    {
        if directions.isEmpty {
            assertionFailure("No directions to translate")
            return viewport
        }

        var x = viewport.originX
        var y = viewport.originY

        // Normalize by number of directions we're moving in, otherwise diagonal move amount is too much
        let amount = directions.count == 2 ? ViewportCoordinatorConstant
            .diagonalTranslationStep : ViewportCoordinatorConstant.translationStep
        for value in directions {
            switch value.direction {
            case .east:
                x += amount * zoomMultiplier * value.magnitude
            case .west:
                x -= amount * zoomMultiplier * value.magnitude
            case .north:
                y += amount * zoomMultiplier * value.magnitude
            case .south:
                y -= amount * zoomMultiplier * value.magnitude
            }
        }
        return MTLViewport(originX: x,
                           originY: y,
                           width: viewport.width,
                           height: viewport.height,
                           znear: viewport.znear,
                           zfar: viewport.zfar)
    }

    // MARK: - variables

    /// Publishes actionsto anyone who listens
    private let publisher = PassthroughSubject<RendererAction, Never>()

    /// This is the user position, including zooming and translation, which sets visibleRegion on set
    private var userPosition: MTLViewport {
        didSet {
            let chunkSizeInPixels = DataProvider.ChunkDataType.chunkSizeInPixels
            visibleRegion = ViewportCoordinator<DataProvider>
                .visibleRegion(from: userPosition, chunkSizeInPixels: chunkSizeInPixels)
            publisher.send(.updateUserPosition(to: userPosition, inDrawableSize: currentDrawableSize))
            debugger?.subject(for: .userViewport).send(userPosition)
        }
    }

    /// The current size of our drawable
    private var currentDrawableSize: CGSize

    /// The current zoom level, within the min and max range
    private var currentZoomLevel: Double = 1.0

    // MARK: - delegates

    weak var dataProvider: DataProvider?
    weak var debugger: DebugProtocol?

    // MARK: - ViewportDataProvider

    /// This is the viewport for drawing, not including translation
    private(set) var currentViewport: MTLViewport {
        didSet {
            debugger?.subject(for: .windowViewport).send(currentViewport)
        }
    }

    /// A rect dictating which chunks are currently visible (in whole chunk-units)
    private(set) var visibleRegion: ChunkRegion {
        didSet {
            publisher.send(.updateVisibleRegion(to: visibleRegion))
        }
    }

    // MARK: - initialization

    /// Initializes the viewports to a size and saves the data provider
    init(initialSize: CGSize, dataProvider: DataProvider?) {
        let chunkSizeInPixels = DataProvider.ChunkDataType.chunkSizeInPixels
        let initialViewport = ViewportCoordinator.viewport(byResizing: MTLViewport(), to: initialSize)
        userPosition = initialViewport
        currentViewport = initialViewport
        currentDrawableSize = .zero
        visibleRegion = ViewportCoordinator<DataProvider>
            .visibleRegion(from: initialViewport, chunkSizeInPixels: chunkSizeInPixels)
        self.dataProvider = dataProvider
    }

    // MARK: - shared methods

    /// Returns the absolute distance squared from a chunk to the user position. Squared for
    /// speed because division is slow.
    func distanceToUserPositionSquared(fromChunk chunk: Chunk) -> Float {
        let point = (userPosition.originX, userPosition.originY)
        let chunkSizeInPixels = DataProvider.ChunkDataType.chunkSizeInPixels
        return ViewportCoordinator<DataProvider>.distanceSquared(fromChunk: chunk,
                                                                 toPixelSpacePoint: point,
                                                                 chunkSizeInPixels: chunkSizeInPixels)
    }

    // MARK: - private helpers

    /// Function for zooming a viewport in or out of the screen, constrained to levels set in constants
    private func viewport(byZooming viewport: MTLViewport,
                          in direction: ZoomDirection,
                          at point: NSPoint,
                          withinSize size: CGSize) -> MTLViewport
    {
        // Change the current zoom level based on direction, bounded to min/max levels
        var changeAmount = 1.0
        switch direction {
        case let .in(amount):
            changeAmount -= amount * ViewportCoordinatorConstant.ZoomLevel.multiplier
        case let .out(amount):
            changeAmount += amount * ViewportCoordinatorConstant.ZoomLevel.multiplier
        }
        let prevZoom = currentZoomLevel
        currentZoomLevel = Swift.max(ViewportCoordinatorConstant.ZoomLevel.min,
                                     Swift.min(ViewportCoordinatorConstant.ZoomLevel.max,
                                               currentZoomLevel * changeAmount))

        // Convert the screen point (0,0 in lower left) to Metal space (0,0 in center), paying attention to pixel density
        let pixelDensity = currentDrawableSize / size
        let normX = Double(pixelDensity.width) * 2 * Double(point.x) - currentViewport.width
        let normY = Double(pixelDensity.height) * 2 * Double(point.y) - currentViewport.height

        // Change the origin based on where we're zooming into
        let originDeltaX = normX * prevZoom - normX * currentZoomLevel
        let originDeltaY = normY * prevZoom - normY * currentZoomLevel

        return MTLViewport(originX: viewport.originX + originDeltaX / Double(pixelDensity.width),
                           originY: viewport.originY + originDeltaY / Double(pixelDensity.width),
                           width: currentViewport.width * currentZoomLevel,
                           height: currentViewport.height * currentZoomLevel,
                           znear: viewport.znear,
                           zfar: viewport.zfar)
    }
}

// MARK: - Publisher

extension ViewportCoordinator: Publisher {
    public typealias Output = RendererAction
    public typealias Failure = Never

    /// Connect the built-in publisher to the subscriber sent
    public func receive<S>(subscriber: S)
        where S: Subscriber,
        ViewportCoordinator.Failure == S.Failure,
        ViewportCoordinator.Output == S.Input
    {
        publisher.subscribe(subscriber)
    }
}

// MARK: - Subscriber

/// Subscribes the map renderer to a chunk coordinator's actions
extension ViewportCoordinator: Subscriber {
    typealias Input = ViewportAction

    /// Request unlimited items
    func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }

    /// Delegate to the right built in function
    func receive(_ action: ViewportAction) -> Subscribers.Demand {
        switch action {
        case let .panViewport(directions: directions):
            panViewport(in: directions)
        case let .resizeViewport(to: size):
            resizeViewport(to: size)
        case let .zoomViewport(direction: direction, point: point, withinSize: size):
            zoomViewport(direction, at: point, withinSize: size)
        }
        return .none
    }

    /// No-op
    func receive(completion _: Subscribers.Completion<Never>) {}

    /// Change the user position only, not the actual viewport
    private func panViewport(in directions: Set<VectoredDirection<Double>>) {
        userPosition = ViewportCoordinator.viewport(byTranslating: userPosition, in: directions,
                                                    atZoom: currentZoomLevel)
    }

    /// Resize both the user position and the actual viewport
    private func resizeViewport(to size: CGSize) {
        currentDrawableSize = size
        userPosition = ViewportCoordinator.viewport(byResizing: userPosition, to: size, atZoom: currentZoomLevel)
        currentViewport = ViewportCoordinator.viewport(byResizing: currentViewport, to: size)
    }

    /// Zooms both the user position and the actual viewport by a certain amount
    private func zoomViewport(_ direction: ZoomDirection, at point: NSPoint, withinSize size: CGSize) {
        userPosition = viewport(byZooming: userPosition, in: direction, at: point, withinSize: size)
    }
}
