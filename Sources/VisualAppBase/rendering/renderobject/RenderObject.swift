import CustomGraphicsMath

// TODO: implement function for checking whether render object has content at certain position (--> is not transparent) --> used for mouse events like click etc.
// TODO: might split into SubTreeRenderObject and LeafRenderObject!!!
public protocol RenderObject {
    typealias IdentifiedSubTree = VisualAppBase.IdentifiedSubTreeRenderObject
    typealias Container = VisualAppBase.ContainerRenderObject
    typealias Uncachable = VisualAppBase.UncachableRenderObject
    typealias CacheSplit = VisualAppBase.CacheSplitRenderObject
    typealias RenderStyle = VisualAppBase.RenderStyleRenderObject
    typealias Rect = VisualAppBase.RectRenderObject
    typealias Custom = VisualAppBase.CustomRenderObject
    typealias Text = VisualAppBase.TextRenderObject
}

public protocol SubTreeRenderObject: RenderObject {
    var children: [RenderObject] { get set }
}

public struct IdentifiedSubTreeRenderObject: SubTreeRenderObject {
    public var id: UInt
    public var children: [RenderObject]

    public init(_ id: UInt, _ children: [RenderObject]) {
        self.id = id
        self.children = children
    }

    public init(_ id: UInt, @RenderObjectBuilder _ children: () -> [RenderObject]) {
        self.id = id
        self.children = children()
    }
}

// TODO: is this needed?
public struct ContainerRenderObject: SubTreeRenderObject {
    public var children: [RenderObject]

    public init(_ children: [RenderObject]) {
        self.children = children
    }

    public init(@RenderObjectBuilder _ children: () -> [RenderObject]) {
        self.children = children()
    }
}

public struct RenderStyleRenderObject: SubTreeRenderObject {
    public var renderStyle: RenderStyle
    public var children: [RenderObject]

    public init(_ renderStyle: RenderStyle, _ children: [RenderObject]) {
        self.renderStyle = renderStyle
        self.children = children
    }

    public init(_ renderStyle: RenderStyle, @RenderObjectBuilder _ children: () -> [RenderObject]) {
        self.renderStyle = renderStyle
        self.children = children()
    }
}

public struct UncachableRenderObject: SubTreeRenderObject {
    public var children: [RenderObject]
    public init(_ children: [RenderObject]) {
        self.children = children
    }
    public init(@RenderObjectBuilder _ children: () -> [RenderObject]) {
        self.children = children()
    }
}

/// Can be used as a wrapper for e.g. calculation heavy CustomRenderObjects
/// which should get their own cache to avoid triggering heavy calculations if
/// other RenderObjects would need an update in a common cache.
public struct CacheSplitRenderObject: SubTreeRenderObject {
    public var children: [RenderObject]
    public init(_ children: [RenderObject]) {
        self.children = children
    }
    public init(@RenderObjectBuilder _ children: () -> [RenderObject]) {
        self.children = children()
    }
}

public struct RectRenderObject: RenderObject {
    public var rect: DRect
    
    public init(_ rect: DRect) {
        self.rect = rect
    }
}

public struct CustomRenderObject: RenderObject {
    public var render: (_ renderer: Renderer) throws -> Void

    public init(_ render: @escaping (_ renderer: Renderer) throws -> Void) {
        self.render = render
    }
}

public struct TextRenderObject: RenderObject {
    public var text: String
    public var topLeft: DVec2
    public var textConfig: TextConfig
    public var maxWidth: Double?    

    public init(_ text: String, topLeft: DVec2, textConfig: TextConfig, maxWidth: Double?) {
        self.text = text
        self.topLeft = topLeft
        self.textConfig = textConfig
        self.maxWidth = maxWidth
    }
}
/*public enum RenderObject {
    case Custom(_ render: (_ renderer: Renderer) throws -> Void)
    indirect case Container(_ children: [Self])
}*/