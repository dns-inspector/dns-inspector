import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
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
                List {
                    Section {
                        Button {

                        } label: {
                            Label("Share TLS Inspector", systemImage: "square.and.arrow.up")
                        }
                        Button {

                        } label: {
                            Label("Rate in App Store", systemImage: "star.circle")
                        }
                        Button {

                        } label: {
                            Label("Provide Feedback", systemImage: "bubble.left.and.bubble.right")
                        }
                    } header: {
                        Text("Share & Feedback")
                    } footer: {
                        Text("App: 1.0.0 (1), OpenSSL: 3.1.2, curl: 8.4.0")
                    }
                    Section {
                        Button {

                        } label: {
                            Label("Contribute to DNS Inspector", systemImage: "terminal")
                        }
                        Button {

                        } label: {
                            Label("Test New Features", systemImage: "plus.message")
                        }
                        Button {

                        } label: {
                            Label("Follow us on Mastodon", systemImage: "person.badge.plus")
                        }
                    } header: {
                        Text("Get Involved")
                    } footer: {
                        Text("DNS Inspector is Free and Libre software licensed under the GNU GPLv3. DNS Inspector is copyright © 2023 Ian Spence.")
                    }
                }
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
