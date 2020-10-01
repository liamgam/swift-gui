open class System {
    public var keyStates = KeyStatesContainer()

    public var cursorRequests: [UInt64: Cursor] = [:] // TODO: maybe handle first come first or z index
    public var nextCursorRequestId: UInt64 = 0
    public var onFrame = EventHandlerManager<Int>()

    public var averageFps = 0 // average FPS over a certain time, TODO: which time?
    
    public init() throws {

    }

    /*open func newWindow() throws -> W {
        fatalError("newWindow() not implemented.")
    }*/

    open func requestCursor(_ cursor: Cursor) -> () -> Void {
        let id = nextCursorRequestId
        cursorRequests[id] = cursor
        nextCursorRequestId += 1
        updateCursor()
        return {
            self.dropCursorRequest(id: id)
        }
    }

    open func dropCursorRequest(id: UInt64) {
        cursorRequests.removeValue(forKey: id)
        updateCursor()
    }

    open func updateCursor() {
        fatalError("updateCursor() not implemented.")
    }
    
    open func mainLoop() throws {
        
        fatalError("mainLoop() not implemented.")
    }

    open func exit() throws {
        fatalError("exit() not implemented.")
    }

    /*public func eventLoop() throws {}

    public func eventLoop() throws {}*/
}
