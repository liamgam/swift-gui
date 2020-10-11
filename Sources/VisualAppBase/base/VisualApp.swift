import Dispatch
import Foundation
import CustomGraphicsMath

// TODO: why is there a specific VisualApp when App also takes a Window?, maybe find a more specific name
open class VisualApp<S: System, W: Window, R: Renderer>: App<S, W> {

    public typealias Renderer = R

    public private(set) var windowContexts: [ObjectIdentifier: WindowContext] = [:] {

        didSet {

            if windowContexts.count == 0 {

                exit()
            }
        }
    }

    public init(system: System, immediate: Bool = false) {

        super.init(system: system)

        _ = system.onTick(onTick)

        _ = system.onFrame(onFrame)
    }

    open func createWindow(background: Color, size: DSize2, immediate: Bool = false) -> Window {
 
        let renderObjectTree = RenderObjectTree()

        let renderObjectTreeRenderer: RenderObjectTreeRenderer

        if immediate {
            
            renderObjectTreeRenderer = ImmediateRenderObjectTreeRenderer(renderObjectTree)

        } else {

            renderObjectTreeRenderer = OptimizingRenderObjectTreeRenderer(renderObjectTree)
        }

        let window = try! Window(background: background, size: size)

        _ = window.onClose { [unowned self] in
            
            let context = windowContexts[ObjectIdentifier(window)]!

            context.treeRenderer.destroy()

            context.renderer.destroy()
        }

        let renderer = createRenderer(for: window) 

        let context = WindowContext(
            window: window,
            renderer: renderer,
            tree: renderObjectTree,
            treeRenderer: renderObjectTreeRenderer)

        windowContexts[ObjectIdentifier(window)] = context

        return window
    }

    open func createRenderer(for window: Window) -> Renderer {

        fatalError("createRenderer(for:) not implemented")
    }

    open func onTick(_ tick: Tick) {

        for context in windowContexts.values {

            context.tree.bus.down(.Tick(tick: tick))

            context.treeRenderer.tick(tick)
        }
    }

    open func onFrame(_ deltaTime: Int) {

        for context in windowContexts.values {

            if context.treeRenderer.rerenderNeeded {

                context.renderer.beginFrame()

                context.treeRenderer.render(with: context.renderer, in: DRect(min: .zero, size: context.window.drawableSize))

                context.renderer.endFrame()

                context.window.updateContent()
            }
        }
    }

    public struct WindowContext {

        public var window: Window

        public var renderer: Renderer

        public var tree: RenderObjectTree

        public var treeRenderer: RenderObjectTreeRenderer
    }
}