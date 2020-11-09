import Foundation
import VisualAppBase
import CustomGraphicsMath

open class WidgetsApp<S: System, W: Window, R: Renderer>: VisualApp<S, W, R> {
    public typealias Renderer = R
    public private(set) var guiRoots: [Int: Root] = [:]

    public init(system: System) {
        super.init(system: system, immediate: true)
    }

    /// - Parameter guiRoot: is an autoclosure. This ensures, that the window
    /// has already been created when the guiRoot is evaluated and e.g. the OpenGL context was created.
    public func createWindow(
        guiRoot guiRootBuilder: @autoclosure () -> Root,
        options: Window.Options,
        immediate: Bool = false) -> Window {
        let window = super.createWindow(
            options: options,
            immediate: immediate)
        let windowId = window.id
        let context = windowContexts[windowId]!
        let guiRoot = guiRootBuilder()

        guiRoot.setup(widgetContext: WidgetContext(
                      window: window,
                      getTextBoundsSize: { [unowned self] in windowContexts[windowId]!.renderer.getTextBoundsSize($0, fontConfig: $1, maxWidth: $2) },
                      getApplicationTime: { [unowned self] in system.currentTime },
                      createWindow: { [unowned self] in createWindow(guiRoot: $0(), options: $1, immediate: true) },
                      requestCursor: { [unowned self] in
                          system.requestCursor($0)
                      }))
      
        guiRoots[windowId] = guiRoot

        guiRoot.bounds.size = window.size
        
        _ = window.onMouse { [unowned self] in
            guiRoots[windowId]!.consume($0)
        }

        _ = window.onKey { [unowned self] in
            guiRoots[windowId]!.consume($0)
        }

        _ = window.onText { [unowned self] in
            guiRoots[windowId]!.consume($0)
        }

        _ = window.onSizeChanged { [unowned self] in
            guiRoots[windowId]!.bounds.size = $0
        }

        #if DEBUG
        _ = window.onKey { [unowned self] in
            if let event = $0 as? KeyUpEvent, event.key == Key.F12 {
                openDevTools(for: windowContexts[windowId]!.window)
           }
        }
        #endif

        _ = window.onBeforeClose { [unowned self] _ in
            guiRoots[windowId]!.destroy()
            guiRoots[windowId] = nil
        }

        if let rendering = guiRoot.render() {
            context.tree.appendChild(rendering)
        }

        return window
    }

    public func openDevTools(for window: Window) {
        let devToolsView = DeveloperToolsView(guiRoots[window.id]!)
        let devToolsGuiRoot = WidgetGUI.Root(
            rootWidget: devToolsView
        )
        createWindow(guiRoot: devToolsGuiRoot, options: Window.Options(
            initialPosition: .Defined(window.position + DVec2(window.size))
        ), immediate: true)
    }

    override public func onTick(_ tick: Tick) {
        for guiRoot in guiRoots.values {
            guiRoot.tick(tick)
        }
        super.onTick(tick)
    }

    override public func renderWindow(_ context: WindowContext) {
        #if DEBUG
        let startTime = Date.timeIntervalSinceReferenceDate
        #endif

        super.renderWindow(context)

        #if DEBUG
        let deltaTime = Date.timeIntervalSinceReferenceDate - startTime
        Logger.log(
            "Took \(deltaTime) seconds for rendering window.",
            level: .Message,
            context: .Performance
        )
        #endif
    }
}
