import PokeFoldersCore
import SwiftUI

extension Binding where Value == IconConfiguration {
    func color(_ keyPath: WritableKeyPath<IconConfiguration, RGBAColor>) -> Binding<Color> {
        Binding<Color>(
            get: { wrappedValue[keyPath: keyPath].swiftUIColor },
            set: { wrappedValue[keyPath: keyPath] = RGBAColor(color: $0) }
        )
    }
}
