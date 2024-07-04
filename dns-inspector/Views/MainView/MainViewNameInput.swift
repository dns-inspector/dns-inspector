import SwiftUI
import DNSKit

struct MainViewNameInput: View {
    @Binding var recordType: RecordType
    @Binding var name: String

    var body: some View {
        HStack {
            Menu {
                ForEach(RecordType.allCases, id: \.self) { t in
                    Button(action: {
                        recordType = t
                    }, label: {
                        Text(t.string())
                    })
                }
            } label: {
                HStack {
                    Text(recordType.string())
                    Image(systemName: "chevron.up.chevron.down")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 12)
                }
            }
            Divider()
            TextField(text: $name) {
                Text(localized: "Name")
            }
            .keyboardType(.URL)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            ClearButton(text: $name)
        }
    }
}
