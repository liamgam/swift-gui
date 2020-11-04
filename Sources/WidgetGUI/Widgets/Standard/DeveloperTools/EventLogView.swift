import CustomGraphicsMath
import VisualAppBase

public class EventLogView: SingleChildWidget {
  private let inspectedRoot: Root

  @ObservableProperty
  private var messages: [WidgetInspectionMessage]

  public let onInspectWidgetRequest = EventHandlerManager<Widget>()

  public init(
    _ inspectedRoot: Root,
    messages observableMessages: ObservableProperty<[WidgetInspectionMessage]>,
    onInspectWidgetRequest inspectWidgetRequestHandler: ((Widget) -> ())? = nil) {
      self.inspectedRoot = inspectedRoot
      self._messages = observableMessages
      if let handler = inspectWidgetRequestHandler {
        onInspectWidgetRequest.addHandler(handler)
      }
  }

  override public func buildChild() -> Widget {
    ScrollArea(scrollX: .Never) { [unowned self] in
      List($messages) {
        buildInspectionMessageItem(message: $0)
      }
    }
  }

  private func buildInspectionMessageItem(message: WidgetInspectionMessage) -> Widget {
    MouseArea {
      Border(bottom: 1, color: Color(0, 0, 0, 40)) {
        Background(fill: .White) {
          Padding(all: 16) {
            Text("\(message.sender): \(message.content)")
          }
        }
      }
    } onClick: { [unowned self] in
      if $0.button == .Left {
        message.sender.flashHighlight()
        onInspectWidgetRequest.invokeHandlers(message.sender)
      } else if $0.button == .Right {
        createContextMenu(for: message.sender, at: $0.position)        
      }
    }
  }

  private func createContextMenu(for widget: Widget, at position: DPoint2) {
    let screenPosition = context.window.position + position
    var window: Window? = nil
    let guiRoot = Root(rootWidget: Column { [unowned self] in
      buildContextMenuItem {
        Row(spacing: 8) {
          if widget.debugLayout {
            MaterialIcon(.check)
          }

          Text("debug layout")
        }
      } action: {
        widget.debugLayout = !widget.debugLayout
        widget.invalidateRenderState()
        window!.close()
      }
    })
    window = context.createWindow(
      guiRoot: guiRoot,
      options: Window.Options(
        initialPosition: .Defined(screenPosition),
        initialVisibility: .Hidden,
        borderless: true))
    window!.size = guiRoot.rootWidget.boxConfig.preferredSize
    _ = window!.onInputFocusChanged {
      if !$0 {
        window!.close()
      }
    }
    nextTick { _ in
      window!.visibility = .Shown
    }
  }

  private func buildContextMenuItem(@WidgetBuilder content: () -> Widget, action: @escaping () -> ()) -> Widget {
    MouseArea {
      Background(fill: .White) {
        Padding(all: 16) {
          content()
        }
      }
    } onClick: { _ in
      action()
    }
  }
}
