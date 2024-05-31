import SwiftUI

struct TitleValue<Content: View>: View {
    let title: String
    let content: () -> Content

    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    init(localizedTitle: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = Localize(localizedTitle)
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.footnote)
                .opacity(0.75)
            HStack(content: content)
        }
    }
}
