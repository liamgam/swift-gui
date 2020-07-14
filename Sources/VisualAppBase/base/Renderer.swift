//

//

import Foundation
import CustomGraphicsMath

struct ImplementationError: Error {
    var message: String
    init() {
        message = "Not implemented."
    }
}

/// Rendering is relative to topLeft of whatever area the renderer is rendering in.
// TODO: maybe rename to CanvasRenderer/DirectRenderer/SimpleRenderer or something like that
public protocol Renderer {
    // TODO: maybe resolution belongs to window?
    //var resolution: Double { get }

    func beginFrame() throws
    func endFrame() throws
    func clear(_ color: Color) throws
    func beginPath() throws
    func fillColor(_ color: Color) throws
    func fill() throws
    func rect(_ rect: DRect) throws
    // TODO: update to remove style argument
    func circle(center: DPoint2, radius: Double, style: RenderStyle) throws
    func ellipse(center: DPoint2, radius: DVec2, style: RenderStyle) throws
    func text(_ text: String, topLeft: DPoint2, fontConfig: FontConfig, color: Color) throws
    func line(from: DPoint2, to: DPoint2, width: Double, color: Color) throws
    func getTextBoundsSize(_ text: String, fontConfig: FontConfig) throws -> DSize2
    func multilineText(_ text: String, topLeft: DPoint2, maxWidth: Double, fontConfig: FontConfig, color: Color) throws
    func getMultilineTextBoundsSize(_ text: String, maxWidth: Double, fontConfig: FontConfig) throws -> DSize2
    func globalOpacity(_ opacity: Float) throws
    func clipArea(bounds: DRect) throws
    func releaseClipArea() throws
    func translate(_ translation: DVec2) throws 
    func scale(_ amount: DVec2) throws
    func resetTransform()
}

/*open class Renderer {//<W: Window> {
    /*open class var vectorLayout: VectorLayout2<DVec2> {
        .defaultLayout
    }*/
    
    //public let window: W

   // public init() {//public init(window: W) {
        //self.window = window
    //}

    public init() {}

    open func beginFrame() throws {
        fatalError("beginFrame() not implemented.")
    }
    open func endFrame() throws {
        fatalError("endFrame() not implemented.")
    }
    open func clear(_ color: Color) throws {
        fatalError("clear() not implemented.")
    }
    open func beginPath() throws {
        fatalError("beginPath() not implemented.")
    }
    open func fillColor(_ color: Color) throws {
        fatalError("fillColor() not implemented.")
    }
    open func fill() throws {
        fatalError("fill() not implemented.")
    }
    open func rect(_ rect: DRect) throws {
        fatalError("rect() not implemented.")
    }
    open func circle(center: DPoint2, radius: Double, style: RenderStyle) throws {
        fatalError("circle() not implemented.")
    }
    open func ellipse(center: DPoint2, radius: DVec2, style: RenderStyle) throws {
        fatalError("ellipse() not implemented.")
    }
    open func text(_ text: String, topLeft: DPoint2, fontConfig: FontConfig, color: Color) throws {
        fatalError("text() not implemented.")
    }
    open func line(from: DPoint2, to: DPoint2, width: Double, color: Color) throws {
        fatalError("line() not implemented.")
    }
    open func getTextBoundsSize(_ text: String, fontConfig: FontConfig) throws -> DSize2 {
        fatalError("getTextSize() not implemented")
    }
    open func multilineText(_ text: String, topLeft: DPoint2, maxWidth: Double, fontConfig: FontConfig, color: Color) throws {
        fatalError("multilineText not implemented.")
    }
    open func getMultilineTextBoundsSize(_ text: String, maxWidth: Double, fontConfig: FontConfig) throws -> DSize2 {
        fatalError("getMultilineTextSize not implemented.")
    }
    open func globalOpacity(_ opacity: Float) throws {
        fatalError("globalOpacity not implemented.")
    }
    open func clipArea(bounds: DRect) throws {
        fatalError("clipArea not implemented.")
    }
    open func releaseClipArea() throws {
        fatalError("releaseClipArea not implemented.")
    }
    open func translate(_ translation: DVec2) throws {
        fatalError("translate not implemented.")
    }
    open func scale(_ amount: DVec2) throws {
        fatalError("scale not implemented.")
    }
    open func resetTransform() {
        fatalError("resetTransform not implemented.")
    }
    /*open func flush() throws {
        fatalError("flush not implemented.")
    }*/
}*/