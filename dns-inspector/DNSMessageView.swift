import SwiftUI
import DNSKit

struct DNSMessageView: View {
    let query: DNSQuery
    let message: DNSMessage

    var body: some View {
        HStack {
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
        }
    }
}
