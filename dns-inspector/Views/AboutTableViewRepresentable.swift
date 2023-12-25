import SwiftUI

struct AboutTableViewRepresentable: UIViewRepresentable {
    typealias UIViewType = AboutTableView

    func makeUIView(context: Context) -> AboutTableView {
        let view = AboutTableView()
        return view
    }

    func updateUIView(_ uiView: AboutTableView, context: Context) {}
}
