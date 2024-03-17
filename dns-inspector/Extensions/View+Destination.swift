import SwiftUI

extension View {
    public func destination<V>(isPresented: Binding<Bool>, @ViewBuilder destination: () -> V) -> some View where V : View {
        if #available(iOS 16, *) {
            return self.navigationDestination(isPresented: isPresented, destination: destination)
        } else {
            return self.background {
                NavigationLink(
                    destination: destination(),
                    isActive: isPresented,
                    label: {
                        EmptyView()
                    })
            }
        }
    }
}
