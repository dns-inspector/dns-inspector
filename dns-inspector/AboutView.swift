import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Navigation {
            VStack {
                VStack {
                    Image(systemName: "link.circle.fill")
                        .resizable(resizingMode: .stretch)
                        .foregroundColor(Color.white)
                        .frame(width: 75.0, height: 75.0)
                    Text("DNS Inspector")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                }
                .frame(maxWidth: .infinity, maxHeight: 250)
                .background(.linearGradient(.init(colors: [Color("Gradient1", bundle: nil), Color("Gradient2", bundle: nil)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                AboutTableViewRepresentable()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                    })
                    .tint(.white)
                }
            }
            .background(Color(uiColor: UIColor.systemGroupedBackground))
        }
    }
}

#Preview {
    AboutView()
}
