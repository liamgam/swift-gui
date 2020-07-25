//

//

import Foundation
import CustomGraphicsMath
import VisualAppBase

public class Text: LeafWidget {
    public var text: String {
        didSet {
            try! layout()
        }
    }

    public var textConfigProvider: TextConfigProvider?
    public var textConfig: TextConfig?

    public var filledTextConfig: TextConfig? {
        return textConfig ??
            textConfigProvider?.textConfig ?? (context != nil ?
            TextConfig(fontConfig: FontConfig(
                family: context!.defaultFontFamily,
                size: 16,
                weight: .Regular,
                style: .Normal
            ), color: .Black, wrap: true)
            : nil)
    }

    public init(_ text: String, config: TextConfig? = nil) {
        self.text = text
        self.textConfig = config
        super.init()
        _ = onAnyParentChanged { _ in
            if let textConfigProvider = self.parentOfType(TextConfigProvider.self) {
                self.textConfigProvider = textConfigProvider
                try! self.layout()
            }
        }
    }

    override public func layout(fromChild: Bool = false) throws {
        //var size = try globalContext!.getTextSize(text: text, fontConfig: fontConfig)
        //self.sizeConfig.width = .Fixed(value: size.width)
        //self.sizeConfig.height = .Fixed(value: size.height)
        // TODO: check whether to have wrap in textConfig, or a property of Text and whether to pass maxWidth extra or put it into textconfig and whether to always pass it
        if let context = context, let textConfig = filledTextConfig {
            var preferredSize = DSize2()
            if textConfig.wrap {
               preferredSize = context.getTextBoundsSize(text, config: textConfig, maxWidth: constraints!.maxWidth)// try context!.renderer.getMultilineTextSize(text, maxWidth: constraints!.maxWidth, fontConfig: textConfig.fontConfig)
            } else {
                preferredSize = context.getTextBoundsSize(text, config: textConfig, maxWidth: constraints!.maxWidth)
            }
            bounds.size = constraints!.constrain(preferredSize)
        }
    }

    /*override public func getContentSize() throws -> DSize2 {
        return try globalContext!.getTextSize(text: text, fontConfig: fontConfig)
    }*/

    override public func render() -> RenderObject? {
        if let textConfig = filledTextConfig {
            return .Text(text, config: textConfig, topLeft: globalPosition, maxWidth: bounds.size.width)
        }
        return nil
    }
}