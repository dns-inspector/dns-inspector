import SwiftUI
import DNSKit

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { frame in
            Navigation {
                VStack {
                    VStack {
                        Image(systemName: "link.circle.fill")
                            .resizable(resizingMode: .stretch)
                            .foregroundColor(Color.white)
                            .frame(width: 75.0, height: 75.0)
                        Text(localized: "DNS Inspector")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: frame.size.height*0.40)
                    .background(.linearGradient(.init(colors: [Color("Gradient1", bundle: nil), Color("Gradient2", bundle: nil)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    AboutTableViewRepresentable()
                }
                .ignoresSafeArea()
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
}
