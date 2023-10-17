import SwiftUI
import DNSKit

struct DNSMessageView: View {
    let query: DNSQuery
    let message: DNSMessage
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Question") {
                    Text("Hi")
                }
                Section("Answer") {
                    Text("Hi")
                }
                Section("Server") {
                    Text("Hi")
                }
            }
            .navigationTitle(query.name)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                    })
                }
            }
        }
    }
}
