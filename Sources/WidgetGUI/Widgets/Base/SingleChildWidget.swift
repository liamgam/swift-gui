import VisualAppBase

open class SingleChildWidget: Widget {
    open lazy var child: Widget = buildChild()
    
    override public init() {
        //self.child = child
        super.init()
        child.parent = self
        // TODO: maybe dangling closure
        _ = child.onRenderStateInvalidated {
            self.invalidateRenderState($0)
        }
        //child.context = context
    }

    open func buildChild() -> Widget {
        fatalError("buildChild() not implemented.")
    }

    override open func layout(fromChild: Bool) throws {
        child.constraints = constraints
        try child.layout()
        bounds.size = child.bounds.size
    }    

    open func render(_ renderedChild: RenderObject?) -> RenderObject? {
        return renderedChild 
    }
}