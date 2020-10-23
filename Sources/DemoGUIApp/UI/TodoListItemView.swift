import WidgetGUI

public class TodoListItemView: SingleChildWidget {
  @Inject
  private var store: TodoStore
  private var item: TodoItem
  private var editable: Bool
  private var checkable: Bool
  public private(set) var onItemUpdated = WidgetEventHandlerManager<TodoItem>()
  @MutableProperty
  private var editing: Bool = false
  private var updatedDescriptionBuffer: String = ""

  public init(_ item: TodoItem, editable: Bool = false, checkable: Bool = true, onItemUpdated onItemUpdatedHandler: ((TodoItem) -> ())? = nil) {
    self.item = item
    self.editable = editable
    self.checkable = checkable
    if let handler = onItemUpdatedHandler {
      _ = onItemUpdated.addHandler(handler)
    }
  }

  override public func buildChild() -> Widget {
    MouseArea { [unowned self] in
      Padding(all: 16) {
        Column(spacing: 24) {
          Row(spacing: 48) {
            Row.Item(crossAlignment: .Center) {
              TaskCompletionButton(StaticProperty(item.completed), color: .Yellow) { _ in
                if checkable {
                  var updatedItem = item
                  updatedItem.completed = !updatedItem.completed
                  store.dispatch(.UpdateTodoItem(updatedItem))
                }
              }
            }

            Row.Item(crossAlignment: .Center) {
              ObservingBuilder($editing) {
                if editing {
                  Row(spacing: 16) {
                    TextField(item.description).onTextChanged.chain {
                      updatedDescriptionBuffer = $0
                    }.requestFocus().onFocusChanged.chain { focused in
                      if !focused {
                        //if editingItemIndex == index {
                          //editingItemIndex = nil
                          //print("WOULD SET NIL")
                        //}
                      }
                    }

                    Button {
                      Text("done")
                    } onClick: { _ in
                      var updatedItem = item
                      updatedItem.description = updatedDescriptionBuffer
                      editing = false
                      store.dispatch(.UpdateTodoItem(updatedItem))
                    }
                  }
                } else {
                  MouseArea {
                    Text(item.description, wrap: true)
                  } onClick: { _ in
                    if editable {
                      editing = true
                      updatedDescriptionBuffer = item.description
                    }
                  }
                }
              }
            }
          }

          /*if expandedItemIndices.contains(index) {
            Row {
              todo.images.map {
                ImageView(image: $0)
              }
            }
          }*/
        }
      }
    }/* onClick: { [unowned self] _ in
      if item.images.count > 0 {
        withChildInvalidation {
          expandedItemIndices.insert(index)
        }
      }
    }*/
  }
}