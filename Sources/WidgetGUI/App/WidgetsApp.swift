import VisualAppBase
import CustomGraphicsMath

open class WidgetsApp<S: System, W: Window, R: Renderer>: VisualApp<S, W> {
    
    public struct WindowConfig {
        
        public var window: Window
        
        public var guiRoot: Root
        
        public var renderer: Renderer
    }
    
    public typealias Renderer = R

    private var windowConfigs = ObservableArray<WindowConfig>()

    public init(system: System) {
        
        super.init(system: system, immediate: true)

        //_ = system.onTick(tick)

        //_ = system.onFrame(render)

        _ = windowConfigs.onChanged { [unowned self] _ in
            
            if windowConfigs.count == 0 {
                
                exit()
            }
        }
    }

    open func createRenderer(for window: Window) -> Renderer {
        
        fatalError("createRenderer() not implemented.")
    }

    /// - Parameter guiRoot: is an autoclosure. This ensures, that the window
    /// has already been created when the guiRoot is evaluated and e.g. the OpenGL context was created.
    public func newWindow(guiRoot guiRootBuilder: @autoclosure () -> Root, background: Color) -> Window {
        
        let window = try! Window(background: background, size: DSize2(500, 500))

        let renderer = createRenderer(for: window)

        let guiRoot = guiRootBuilder()

        guiRoot.widgetContext = WidgetContext(
            
            window: window,
            
            getTextBoundsSize: { renderer.getTextBoundsSize($0, fontConfig: $1, maxWidth: $2) },

            getApplicationTime: { [unowned self] in system.currentTime },
            
            requestCursor: {
                
                self.system.requestCursor($0)
            })

        // TODO: this should be created in VisualApp, rendering the tree should probably be handled there

        /*guiRoot.renderObjectContext = RenderObject.Context(

            getTextBoundsSize: { renderer.getTextBoundsSize($0, fontConfig: $1, maxWidth: $2) }
        )*/

        guiRoot.bounds.size = window.size
        
        _ = window.onMouse {
            
            guiRoot.consume($0)
        }

        _ = window.onKey {
            
            guiRoot.consume($0)
        }

        _ = window.onText {
            
            guiRoot.consume($0)
        }

        _ = window.onResize {
            
            guiRoot.bounds.size = $0
        }

        _ = window.onKey { [unowned self] in

            if let event = $0 as? KeyUpEvent, event.key == Key.F12 {

                let devToolsView = DeveloperToolsView()

                let devToolsGuiRoot = WidgetGUI.Root(
                    
                    rootWidget: devToolsView
                )

                let removeDebuggingDataHandler = guiRoot.onDebuggingDataAvailable {
                    
                    devToolsView.debuggingData = $0
                }

                let devToolsWindow = newWindow(guiRoot: devToolsGuiRoot, background: .Grey)
               
                _ = devToolsWindow.onKey {

                    if let event = $0 as? KeyUpEvent, event.key == Key.Escape {
                        
                        removeDebuggingDataHandler()
                        
                        devToolsWindow.close()
                    }
                }
            }
        }

        _ = window.onClose { [unowned self] in
            
            guiRoot.destroy()
            
            windowConfigs.removeAll(where: { $0.window === window })
        }

        windowConfigs.append(WindowConfig(window: window, guiRoot: guiRoot, renderer: renderer))

        return window
    }

    override public func onTick(_ tick: Tick) {

        for windowConfig in windowConfigs {

            windowConfig.guiRoot.tick(tick)
        }
    }

    override public func onFrame(_ deltaTime: Int) {
                      
        for windowConfig in windowConfigs {
                               
            if windowConfig.guiRoot.rerenderNeeded {
                
                print("RERENDERING")
                
                windowConfig.renderer.beginFrame()
                
                windowConfig.renderer.clear(windowConfig.window.background)
                
                windowConfig.guiRoot.render(
                    with: windowConfig.renderer,
                    in: DRect(min: .zero, size: windowConfig.window.drawableSize))
                
                windowConfig.renderer.endFrame()
                
                windowConfig.window.updateContent()
            }
        }
    }

    override open func exit() {
        
        try! system.exit()
    }
}
