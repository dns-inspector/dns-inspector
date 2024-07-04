import SwiftUI
import DNSKit

struct DNSQuestionView: View {
    let question: Question

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(question.name)
                    .font(Font.body.bold().smallCaps())
            }
            .padding(8.0)
            .frame(maxWidth: .infinity)
            .background(Color("LightBackground", bundle: nil))
            HStack {
                Spacer()
                Text(question.recordType.string())
                    .font(Font.body.smallCaps())
                    .padding(.vertical, 8.0)
                Spacer()
                Divider()
                Spacer()
                Text(question.recordClass.string())
                    .font(Font.body.smallCaps())
                    .padding(.vertical, 8.0)
                Spacer()
            }.padding(.top, -8)
        }
        .frame(maxWidth: .infinity)
        .listRowInsets(EdgeInsets())
    }
}
