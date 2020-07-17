import CSDL2
import GL
import Cnanovg
import CustomGraphicsMath
import GLGraphicsMath
import VisualAppBase
import Path

// TODO: maybe put into another file
/*public protocol SDL2OpenGL3NanoVGVirtualScreen: VirtualScreen {
    var framebuffer: GLMap.UInt { get set }
    var texture: GLMap.UInt { get set }
}*/

public struct SDL2OpenGL3NanoVGVirtualScreen: VirtualScreen {
    public var size: DSize2
    public var framebuffer = GLMap.UInt()
    public var texture = GLMap.UInt()

    public init(_ size: DSize2) {
        self.size = size
    }

    public func delete() throws {
        glDeleteFramebuffers(1, [framebuffer])
        glDeleteTextures(1, [texture])
    }
}

open class SDL2OpenGL3NanoVGRenderer: Renderer {
    // TODO: maybe this has to be put into System? or does NanoVG load it into the current gl state???
    //public typealias VirtualScreen = SDL2OpenGL3NanoVGVirtualScreen
    
    private var fontIds = [String: Int32]()

    private var window: SDL2OpenGL3NanoVGWindow
    
    private var compositionShader = Shader(
        vertex: try! String(contentsOf: Path.cwd/"Sources/VisualAppBaseImplSDL2OpenGL3NanoVG/shaders/guiVertex.glsl"),
        fragment: try! String(contentsOf: Path.cwd/"Sources/VisualAppBaseImplSDL2OpenGL3NanoVG/shaders/guiFragment.glsl")
    )
    private var compositionVAO = GLMap.UInt()

    public init(window: SDL2OpenGL3NanoVGWindow) {
        self.window = window
        setup()
    }

    public func setup() {
        glGenVertexArrays(1, &compositionVAO)
        glBindVertexArray(compositionVAO)

        var compositionVBO = GLMap.UInt()
        var vertices: [Float] = [
            -1, -1, 0.5,
            1, -1, 0.5,
            1, 1, 0.5,
            -1, -1, 0.5,
            1, 1, 0.5,
            -1, 1, 0.5
        ]
        glGenBuffers(1, &compositionVBO)
        glBindBuffer(GLMap.ARRAY_BUFFER, compositionVBO)
        glBufferData(GLMap.ARRAY_BUFFER, 3 * 6 * MemoryLayout<Float>.stride, vertices, GLMap.STATIC_DRAW)

        glVertexAttribPointer(0, 3, GLMap.FLOAT, false, GLMap.Size(3 * MemoryLayout<Float>.stride), nil)
        glEnableVertexAttribArray(0)

        glBindBuffer(GLMap.ARRAY_BUFFER, 0)

        glBindVertexArray(0)
        glBindTexture(GLMap.TEXTURE_2D, 0)

        try! compositionShader.compile()
    }

    public var nvg: UnsafeMutablePointer<NVGcontext> {
        get {
            window.nvg
        }
    }

    private func loadFont(_ path: String) -> Bool {
        let id = nvgCreateFont(window.nvg, path, path)
        if id > -1 {
            fontIds[path] = id
        }
        print("Loaded font from", path, id)
        return id > -1
    }

    open func clear(_ color: Color) throws {
        GL.glClearColor(color.glR, color.glG, color.glB, color.glA)
        GL.glClear(GLMap.COLOR_BUFFER_BIT)
    }

    open func beginFrame() throws {
        SDL_GL_MakeCurrent(window.sdlWindow, window.glContext)
        glViewport(x: 0, y: 0, width: GLMap.Size(window.drawableSize.width), height: GLMap.Size(window.drawableSize.height))
        nvgBeginFrame(window.nvg, Float(window.size.width), Float(window.size.height), window.pixelRatio)
    }

    open func endFrame() throws {
	    nvgEndFrame(window.nvg)
    }

    open func makeVirtualScreen(size: DSize2) throws -> VirtualScreen {
        var screen = SDL2OpenGL3NanoVGVirtualScreen(size)
        glGenFramebuffers(1, &screen.framebuffer)
        glBindFramebuffer(GLMap.FRAMEBUFFER, screen.framebuffer)

        glGenTextures(1, &screen.texture)
        glBindTexture(GLMap.TEXTURE_2D, screen.texture)
        glTexImage2D(GLMap.TEXTURE_2D, 0, GLMap.RGB, GLMap.Size(size.width), GLMap.Size(size.height), 0, GLMap.RGB, GLMap.UNSIGNED_BYTE, nil)
        glTexParameteri(GLMap.TEXTURE_2D, GLMap.TEXTURE_MIN_FILTER, GLMap.LINEAR)
        glTexParameteri(GLMap.TEXTURE_2D, GLMap.TEXTURE_MAG_FILTER, GLMap.LINEAR)
        glBindTexture(GLMap.TEXTURE_2D, 0)

        glFramebufferTexture2D(GLMap.FRAMEBUFFER, GLMap.COLOR_ATTACHMENT0, GLMap.TEXTURE_2D, screen.texture, 0)
        
        glBindFramebuffer(GLMap.FRAMEBUFFER, 0)

        return screen
    }

    // TODO: maybe handle resizing differently? is inplace modification really required?
    open func resizeVirtualScreen(_ screen: inout VirtualScreen, _ size: DSize2) throws {
        if !(screen is SDL2OpenGL3NanoVGVirtualScreen) {
            fatalError("Unsupported type of VirtualScreen passed to renderer.")
        }
        screen.size = size
        glBindTexture(GLMap.TEXTURE_2D, (screen as! SDL2OpenGL3NanoVGVirtualScreen).texture)
        glTexImage2D(GLMap.TEXTURE_2D, 0, GLMap.RGB, GLMap.Size(size.width), GLMap.Size(size.height), 0, GLMap.RGB, GLMap.UNSIGNED_BYTE, nil)
        glBindTexture(GLMap.TEXTURE_2D, 0)
    }

    open func bindVirtualScreen(_ screen: VirtualScreen) throws {
        guard let screen = screen as? SDL2OpenGL3NanoVGVirtualScreen else {
            fatalError("Unsupported type of VirtualScreen passed to renderer.")
        }
        glBindFramebuffer(GLMap.FRAMEBUFFER, screen.framebuffer)
        glViewport(0, 0, GLMap.Size(screen.size.width), GLMap.Size(screen.size.height))
    }

    open func unbindVirtualScreen() throws {
        glBindFramebuffer(GLMap.FRAMEBUFFER, 0)
        glViewport(0, 0, GLMap.Size(window.drawableSize.width), GLMap.Size(window.drawableSize.height))
    }

    open func drawVirtualScreens(_ screens: [VirtualScreen], at positions: [DVec2]? = nil) throws {
        guard let screen = screens[0] as? SDL2OpenGL3NanoVGVirtualScreen else {
            fatalError("Unsupported type of VirtualScreen passed to renderer.")
        }
        // TODO: implement rendering of all in array
        let positions = positions ?? screens.map { _ in DVec2.zero }
        let translation = positions[0] * DVec2(1, -1) / DVec2(window.drawableSize)
        print("DRAW SCREEN", screen, positions, translation)
        compositionShader.use()
        glUniform2fv(glGetUniformLocation(compositionShader.id!, "translation"), 1, translation.map(Float.init))
        glBindTexture(GLMap.TEXTURE_2D, screen.texture)
        glBindVertexArray(compositionVAO)
        glDrawArrays(GLMap.TRIANGLES, 0, 6)
        glBindTexture(GLMap.TEXTURE_2D, 0)
        glBindVertexArray(0)
    }

    open func beginPath() throws {
        nvgBeginPath(window.nvg)
    }

    open func fillColor(_ color: Color) throws {
        nvgFillColor(window.nvg, color.toNVG())
    }

    open func fill() throws {
        nvgFill(window.nvg)
    }

    open func strokeWidth(_ width: Double) throws {
        nvgStrokeWidth(window.nvg, Float(width))
    }

    open func strokeColor(_ color: Color) throws {
        nvgStrokeColor(window.nvg, color.toNVG())
    }

    open func stroke() throws {
        nvgStroke(window.nvg)
    }

    open func rect(_ rect: DRect) throws {
        //nvgBeginPath(window.nvg)
        nvgRect(window.nvg, Float(rect.topLeft.x), Float(rect.topLeft.y), Float(rect.size.width), Float(rect.size.height))
        //if let fillColor = style.fillColor {
        //    nvgFillColor(window.nvg, fillColor.toNVG())
        //    nvgFill(window.nvg)
        //}
    }

    open func line(from: DPoint2, to: DPoint2, width: Double, color: Color) throws {
        nvgBeginPath(window.nvg)
        nvgMoveTo(window.nvg, Float(from.x), Float(from.y))
        nvgLineTo(window.nvg, Float(to.x), Float(to.y))
        nvgStrokeWidth(window.nvg, Float(width))
        nvgStrokeColor(window.nvg, color.toNVG())
        nvgStroke(window.nvg)
    }

    open func circle(center: DPoint2, radius: Double, style: RenderStyle) throws {
        nvgBeginPath(window.nvg)
        nvgCircle(window.nvg, Float(center.x), Float(center.y), Float(radius))
        if let fillColor = style.fillColor {
            nvgFillColor(window.nvg, fillColor.toNVG())
            nvgFill(window.nvg)
        }
    }

    public func ellipse(center: DPoint2, radius: DVec2, style: RenderStyle) throws {
        fatalError("ellipse not implemented")
    }

    private func applyFontConfig(_ config: FontConfig) {
        if fontIds[config.face.path] == nil {
            loadFont(config.face.path)
        }
        nvgFontFaceId(window.nvg, fontIds[config.face.path]!)
        nvgFontSize(window.nvg, Float(config.size))
        nvgTextAlign(window.nvg, Int32(NVG_ALIGN_LEFT.rawValue | NVG_ALIGN_TOP.rawValue))
    }

    open func text(_ text: String, topLeft: DPoint2, fontConfig: FontConfig, color: Color) throws {
        nvgBeginPath(window.nvg)
        applyFontConfig(fontConfig)
        nvgFillColor(window.nvg, color.toNVG())
        nvgText(window.nvg, Float(topLeft.x), Float(topLeft.y), text, nil)
    }

    open func getTextBoundsSize(_ text: String, fontConfig: FontConfig) throws -> DSize2 {
        applyFontConfig(fontConfig)
        var bounds = [Float](repeating: 0, count: 4)
        nvgTextBounds(window.nvg, 0, 0, text, nil, &bounds)
        return DSize2(Double(bounds[2]), Double(bounds[3]))
    }

    open func multilineText(_ text: String, topLeft: DPoint2, maxWidth: Double, fontConfig: FontConfig, color: Color) throws {
        nvgBeginPath(window.nvg)
        applyFontConfig(fontConfig)
        nvgFillColor(window.nvg, color.toNVG())
        nvgTextBox(window.nvg, Float(topLeft.x), Float(topLeft.y), Float(maxWidth), text, nil)
    }

    open func getMultilineTextBoundsSize(_ text: String, maxWidth: Double, fontConfig: FontConfig) throws -> DSize2 {
        applyFontConfig(fontConfig)
        var bounds = [Float](repeating: 0, count: 4)
        nvgTextBoxBounds(window.nvg, 0, 0, Float(maxWidth), text, nil, &bounds)
        return DSize2(Double(bounds[2]), Double(bounds[3]))
    }

    open func globalOpacity(_ opacity: Float) throws {
        nvgGlobalAlpha(window.nvg, opacity)
    }

    open func clipArea(bounds: DRect) throws {
        nvgScissor(window.nvg, Float(bounds.topLeft.x), Float(bounds.topLeft.y), Float(bounds.size.width), Float(bounds.size.height))
    }

    open func releaseClipArea() throws {
        nvgResetScissor(window.nvg)
    }

    open func scale(_ amount: DVec2) throws {
        nvgScale(window.nvg, Float(amount.x), Float(amount.y))
    }

    open func translate(_ translation: DVec2) throws {
        nvgTranslate(window.nvg, Float(translation.x), Float(translation.y))
    }

    open func resetTransform() {
        nvgResetTransform(window.nvg)
    }

    /*open func flush() throws {
        SDL_GL_SwapWindow(window.sdlWindow)
    }*/
}