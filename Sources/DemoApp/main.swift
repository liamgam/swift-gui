import VisualAppBase
import VisualAppBaseImplSDL2OpenGL3NanoVG
import WidgetGUI
import Dispatch
import CustomGraphicsMath
import Path
import GL
import CSDL2

// TODO: create a subclass of App, DesktopApp which supports windows/screens which can support different resolutions --> renderContexts --> different text boundsSize
open class TwoDGraphicalApp: WidgetsApp<SDL2OpenGL3NanoVGSystem, SDL2OpenGL3NanoVGWindow, SDL2OpenGL3NanoVGRenderer> {
    open var guiRoot: WidgetGUI.Root
    open var devToolsGuiRoot: WidgetGUI.Root
    open var devToolsView: DeveloperToolsView

    private var cacheFramebuffer = GLMap.UInt()
    private var cacheTexture = GLMap.UInt()
    private var cacheDepthStencil = GLMap.UInt()
    private var screenVAO = GLMap.UInt()
    private var virtualScreen: VirtualScreen?

    public init() {
        let page = TwoDWorldPage()
        guiRoot = WidgetGUI.Root(
            rootWidget: page)

        let devToolsView = DeveloperToolsView()
        devToolsGuiRoot = WidgetGUI.Root(
            rootWidget: devToolsView
        )
        self.devToolsView = devToolsView

        super.init(system: try! System())

        _ = guiRoot.onDebuggingDataAvailable {
            self.devToolsView.debuggingData = $0
        }

        newWindow(guiRoot: guiRoot, background: .Grey)
        newWindow(guiRoot: devToolsGuiRoot, background: .Grey)
    }

    override open func createRenderer(for window: Window) -> Renderer {
        return SDL2OpenGL3NanoVGRenderer(window: window)
    }
}

let app = TwoDGraphicalApp()

do {
    try app.start()
} catch {
    print("Error while running app", error)
}