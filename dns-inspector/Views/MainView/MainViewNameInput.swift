import SwiftUI

struct MainViewNameInput: View {
    @Binding var recordType: RecordType
    @Binding var name: String

    var body: some View {
        HStack {
            Menu {
                ForEach(RecordTypes) { t in
                    Button(action: {
                        recordType = t
                    }, label: {
                        Text(t.name)
                    })
                }
            } label: {
                HStack {
                    Text(recordType.name)
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
