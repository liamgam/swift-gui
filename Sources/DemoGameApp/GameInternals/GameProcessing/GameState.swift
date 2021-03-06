import GfxMath

public class GameState {
    public var chunks = [GameChunk]()
    public var playerBlobs = [UInt: PlayerBlob]()
    public var areaBounds = DRect(min: DPoint2(-1000, -1000), max: DPoint2(1000, 1000))
    private var eventBuffers = [UInt: GameEventBuffer]()
    private var nextEventBufferId: UInt = 0

    public init() {
        let chunkCount = IVec2((areaBounds.size / GameChunk.size).rounded(.up))
        for x in 0..<chunkCount.x {
            for y in 0..<chunkCount.y {
                let index = IVec2(x, y)
                chunks.append(GameChunk(index: index))
            }
        }
    }

    public func register(buffer: GameEventBuffer) -> UInt {
        eventBuffers[nextEventBufferId] = buffer
        defer { nextEventBufferId += 1 }
        return nextEventBufferId
    }

    public func unregister(bufferId: UInt) {
        eventBuffers[bufferId] = nil
    }

    public func record(event: GameEvent) {
        for buffer in eventBuffers.values {
            buffer.add(event: event)
        }
    }

    public func add(blob: FoodBlob) {
        guard let chunk = chunkAt(blob.position) else {
            preconditionFailure("No chunk found that can accomodate blob \(blob)")
        }
        chunk.blobs[blob.id] = blob
        // TODO: record event, also record added to which chunk maybe
    }

    public func add(blob: PlayerBlob) {
        playerBlobs[blob.id] = blob
        // TODO: record event, also record added to which chunk maybe
    }

    public func chunkAt(_ position: DVec2) -> GameChunk? {
        let index = IVec2((position - areaBounds.min) / DVec2(GameChunk.size))
        for chunk in chunks {
            if chunk.index == index {
                return chunk
            }
        }
        return nil
    }

    public func findChunks(intersecting selectedAreaBounds: DRect) -> [GameChunk] {
        var result: [GameChunk] = []
        for chunk in chunks {
            let min = areaBounds.min + DVec2(GameChunk.size) * DVec2(chunk.index)
            let max = areaBounds.min + DVec2(GameChunk.size) * DVec2(chunk.index) + DVec2(GameChunk.size)
            let chunkBounds = DRect(min: min, max: max)
            if selectedAreaBounds.contains(point: min) || selectedAreaBounds.contains(point: max) ||
                chunkBounds.contains(point: selectedAreaBounds.min) || chunkBounds.contains(point: selectedAreaBounds.max) {
                    result.append(chunk)
                }
        }
        return result
    }
}