# Styling

This document defines the styling functionality that should be provided by the framework.

At the moment it will the basis for implementing, later it will serve as documentation.

<br>

# Targetted Syntax

    Main {
      // the styles inserted by StyleProvider should only be checked for a
      // selector match with the children of StyleProvider, Widgets outside of it
      // remain unaffected by the provided styles,
      // even if their selectors match
      StyleProvider {
        Text.Style(".button-text") {
          $0.fontSize = 16
          $0.fontWeight = .bold
          $0.foreground = .black
        })

        Button.Style(".default-button") {
          // this transition means: whenever the active style is this one,
          // start a transition of the given duration towards the currently
          // active background fill
          $0.backgroundTransition = Transition(duration: 0.1)
          // .background should be a property of type Fill, which is a protocol that Color, Gradient, Image, ... should conform to
          $0.background = Color.blue
        }.sub {
          // append nested styles that are only checked for a match when the parent selector matches

          // & means: extend the parent selector by what follows after &
          // :hover means: pseudo class hover, that is available on Button
          Button.Style("&:hover", Button.Style) {
            $0.backgroundTransition = Transition(duration: 0.2)
            $0.background = Color.red
          }.sub {
            Text.Style {
              $0.foreground = .white
            }
          }

          // it should be possible to perform matching by checking all
          // Widgets with a custom match function
          Button.Style("&:hover", { ($0 as? Button)?.text == "button1" }) {
            // the transition defined in the $:hover style above should apply here as well,
            $0.background = Color.orange
          }.sub {
            Text.Style {
              $0.foreground = .yellow
            }
          }

          // The StyleContext object should provide an easy way to access all the other
          // styles that apply to the same element as this style, handling overwriting by preferring later definitions over earlier definitions on a per property basis.
          // Whenever a style in the context is updated, removed, added, the following style needs to be recomputed. If other styles depend on it
          // these will then also be recomputed.
          Button.Style("$:active") { (context: StyleContext) in {
              //context.get(AnyStyle.self) should go through all styles that apply to this element before the current style and look for any styles that conform to BackgroundStyle and return the merged properties as an AnyBackgroundStyle 
              // the context should store information about which styles were accessed and therefore are dependencies of this style
              // use this information to reduce number of unnecessary rebuilds (e.g. a parent is updated but it is anyway of a different type, or anyway overwritten by the children or something like that)
              $0.background = (context.get(BackgroundStyle.self, AnyBackgroundStyle.self)?.background as? Color)?.darken(10) ?? Color.red
            }
          // a reactive style can have reactive and non-reactive sub styles
          }.sub { (context: StyleContext) in
            ...
          }.sub {
            ...
          }

          // ForegroundStyle and BackgroundStyle should be protocols
          // which elements like Text, Button conform to. If only the properties
          // need to be set, on a selector which selects different types of elements, 
          // use the AnyStyleProtocol struct implementation of the protocol.
          // The Widget should accept these basic types as styles and apply them.
          AnyForegroundStyle(".foreground-highlight) {
            $0.foreground = .red
          }

          AnyBackgroundStyle(".background-highlight) {
            $0.background = .blue
          }
        }
      } {
        Column {
          Button {
            Text("button1").with(class: "button-text")
          }.with(class: "default-button")

          Button {
            Text("button2").with(class: "button-text")
          }.with(class: "default button")

          Text("This is a description.").with(class: "description").with(style: Text.Style {
            $0.fontSize = 18
            $0.fontWeight = .normal
          })

          Card {
            Row {
              Icon(...).with(class: "foreground-highlight")
              Text(...).with(class: "foreground-highlight")
            }

            RichText { ... }

            Text(...).with(class: "background-highlight")            
          }
        }
      }
    }

# Needing Clarification

- are styles reactive? and if so at what level? at each property? or for each Style element, and where do the dependencies for the reactive calculation come from? from the Widget --> properties?

- how powerful are the styles?
  - can they hide Widgets?
  - can they move Widgets around?
  - can they change content such as text?
  - can they create new Widgets?
  - can they apply e.g. a background color to every Widget regardless of whether
  it has a child Background Widget or not?
  - can a Style definition accesss it's parents / siblings (matching Styles)

- how to approach common values?
  - such as foregroundColor, backgroundColor, opacity, debugLayout, ....
  - should each style match a WidgetStyle protocol?
  - and if only unspecific (shared) properties need to be set on a variety of
  Widgets of a different type there should be a AnyWidgetStyle struct which implements WidgetStyle?

- what to do if a wrong specific Widget style is applied to a Widget?
  - crash?
  - isolate the properties that are shared, by protocols such as WidgetStyle and use them anyway?

- how are pseudo classes managed?
  - a button for example may have :hover, :active and :disabled
  - there might be other Widgets and custom Button Widgets made by library users which
  have the same pseudo classes
  - there might be Widgets that don't share any pseudo classes with other Widgets
  - pseudo classes are probably mostly used for state management, like for the button or maybe a :loading pseudo-class for a Widget that loads something, e.g. an Image, could then use this Information for some convenient styling