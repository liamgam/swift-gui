import VisualAppBase
import GfxMath
import ReactiveProperties

public class ThemeProvider: ConfigProvider {
    public init(_ theme: Theme, @WidgetBuilder child childBuilder: @escaping () -> Widget) {
        super.init(StaticProperty(theme.configs), child: childBuilder)
    }
}