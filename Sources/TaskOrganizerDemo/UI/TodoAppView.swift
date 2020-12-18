import SwiftGUI

public class TodoAppView: SingleChildWidget {
  public enum Mode {
    case SelectedList, Search
  }

  @Inject
  private var store: TodoStore

  /*private var todoLists: [TodoList] {
    store.state.lists
  }*/

  @Reference
  private var activeViewTopSpace: Space
  @MutableProperty
  private var mode: Mode = .SelectedList
  @MutableProperty
  private var searchQuery: String = ""

  public init() {
    super.init()
  }

  override public func buildChild() -> Widget {
    ThemeProvider(appTheme) { [unowned self] in
      Background(fill: appTheme.backgroundColor) { [unowned self] in
        Column(spacing: 32) {
          Column.Item(grow: 1, crossAlignment: .Stretch) {
            Row {
              Row.Item(grow: 0, crossAlignment: .Stretch) {
                buildMenu()
              }

              Row.Item(grow: 1, crossAlignment: .Stretch) {
                buildActiveView()
              }
            }
          }
        }
      }
    }
  }

  private func buildMenu() -> Widget {
    RenderGroup {
      ConstrainedSize(minSize: DSize2(400, 0), maxSize: DSize2(400, .infinity)) {
        Border(right: 1, color: appTheme.backgroundColor.darkened(40)) {
          Column { [unowned self] in
            Column.Item(crossAlignment: .Stretch) {
              buildSearch()
            }

            Padding(all: 32) {
              Button {
                ExperimentalText("New List").with(properties: ExperimentalText.StyleProperties {
                  $0.foreground = Color.black
                  $0.fontWeight = .bold
                })
              } onClick: { [unowned self] _ in
                handleNewListClick()
              }.provideStyles {
                ExperimentalText.Style {
                  $0.fontSize = 30
                }
              }
            }

            Column.Item(crossAlignment: .Stretch) {
              List(store.$state.compute { $0.lists }) {
                buildMenuListItem(for: $0)
              }
            }
          }
        }
      }
    }
  }

  private func buildSearch() -> Widget {
    Background(fill: appTheme.backgroundColor) { [unowned self] in
      Padding(all: 32) {
        Row(spacing: 0) {
          Row.Item(grow: 1, margins: Margins(right: 24)) {
            {
              let textField = TextField(store.state.searchResult?.query ?? "")

              _ = onDestroy(textField.$text.onChanged {
                store.dispatch(.Search($0.new))
              })
              
              _ = onDestroy(textField.onFocusChanged {
                if $0 {
                  mode = .Search
                }
              })

              return textField
            }()
          }

          Row.Item(crossAlignment: .Center) {
            Spaceholder(display: ComputedProperty<Bool>([$mode.any]) { [unowned self] in
              return mode == .Search
            }, dimension: .Vertical) {
              Button {
                Text("cancel")
              } onClick: { _ in
                mode = .SelectedList
              }
            }
          }
        }
      }
    }
  }

  private func buildMenuListItem(for list: TodoList) -> Widget {
    MouseArea {
      MouseInteraction {
        Border(bottom: 2, color: appTheme.backgroundColor.darkened(40)) {
          Background {
            Padding(top: 16, right: 32, bottom: 16, left: 32) {
              Row(spacing: 16) {
                Row.Item(crossAlignment: .Center) {
                  Background(fill: list.color) {
                    Padding(all: 8) {
                      MaterialIcon(.formatListBulletedSquare, color: .white)
                    }
                  }
                }

                Row.Item(crossAlignment: .Center) {
                  ExperimentalText(list.name).with(classes: ["list-item-name"])
                }
              }
            }.provideStyles {
              ExperimentalText.Style(WidgetSelector(classes: ["list-item-name"])) {
                $0.foreground = .white
              }
            }
          }
        }
      }.with(
        config: MouseInteraction.PartialConfig {
          $0.stateConfigs = [
            .Normal: Background.PartialConfig {
              $0.fill = appTheme.backgroundColor
              $0.fillTransition = Background.FillTransition(duration: 0.3)
            },
            .Hover: Background.PartialConfig {
              $0.fill = list.color
              $0.fillTransition = Background.FillTransition(duration: 0.3)
            },
            .Active: Background.PartialConfig {
              $0.fill = list.color.darkened(50)
              $0.fillTransition = Background.FillTransition(duration: 0.3)
            },
          ]
        })
    } onClick: { [unowned self] _ in
      store.commit(.SelectList(list.id))
      mode = .SelectedList
    }
  }

  private func buildActiveView() -> Widget {
    return Background(fill: appTheme.backgroundColor) { [unowned self] in
      Column {
        Space(DSize2(0, 0)).connect(ref: $activeViewTopSpace)

        Column.Item(grow: 1, crossAlignment: .Stretch) {
          Padding(all: 32) {
            ObservingBuilder($mode) {
              switch mode {
              case .SelectedList:
                return ObservingBuilder(store.getters.$selectedList.compute { $0?.id }) {
                  if let list = store.getters.selectedList {
                    return TodoListView(store.getters.$selectedList.compute { $0! })
                  } else {
                    return Center {
                      Text("No list selected.", fontSize: 24, fontWeight: .bold, color: .grey)
                    }
                  }
                }

              case .Search:
                return SearchResultsView()
              }
            }
          }
        }
      }
    }
  }

  private func handleNewListClick() {
    store.commit(.AddList)
  }
}
