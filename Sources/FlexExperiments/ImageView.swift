import WidgetGUI
import VisualAppBase
import CustomGraphicsMath
import Foundation
import Dispatch

public class ImageView: Widget, BoxWidget {
    private var image: Image

    private var resizedImage: Image?
    private var resizingImage = false
    
    public init(image: Image) {
       self.image = image
    }

    public func getBoxConfig() -> BoxConfig {
        BoxConfig(preferredSize: DSize2(Double(image.width), Double(image.height)))
    }

    override public func renderContent() -> RenderObject? {
        if bounds.size.width <= 0 || bounds.size.height <= 0 {
            return nil
        }

        if !resizingImage && (resizedImage == nil || resizedImage!.width != Int(bounds.size.width) || resizedImage!.height != Int(bounds.size.height)) {
            
            resizingImage = true
            
            DispatchQueue.global(qos: .userInteractive).async { [unowned self] in
                let startTimestamp = Date.timeIntervalSinceReferenceDate
                let resizedImage = image.resize(width: Int(bounds.size.width), height: Int(bounds.size.height))
                let endTimestamp = Date.timeIntervalSinceReferenceDate

                DispatchQueue.main.async {
                    self.resizedImage = resizedImage
                    resizingImage = false
                    invalidateRenderState()
                }
            }

            return nil

        } else if resizedImage != nil {

            return RenderObject.RenderStyle(fill: FixedRenderValue(.Image(resizedImage!/*, hash: imageHash!*/, position: globalBounds.min))) {
                RenderObject.Rectangle(globalBounds)
            }

        } else {
            return nil
        }
    }

    override public func performLayout() {
        
    }
}