import SwiftUI
import DNSKit

struct RecordViewDS: View {
    let data: DSRecordData

    var body: some View {
        VStack(alignment: .leading) {
            TitleValue(localizedTitle: "Key tag") {
                Text(String(data.keyTag))
            }.padding(.bottom, 2)
            TitleValue(localizedTitle: "Algorithm") {
                switch data.algorithm {
                case .ECDSAP384_SHA384:
                    Text("ECDSA-P384 with SHA-384")
                case .ECDSAP256_SHA256:
                    Text("ECDSA-P256 with SHA-256")
                case .RSA_SHA512:
                    Text("RSA with SHA-512")
                case .RSA_SHA256:
                    Text("RSA with SHA-256")
                case .RSA_SHA1:
                    Text("RSA with SHA1")
                }
            }.padding(.bottom, 2)
            TitleValue(localizedTitle: "Digest") {
                switch data.digestType {
                case .SHA1:
                    Text("SHA1")
                case .SHA256:
                    Text("SHA-256")
                case .SHA384:
                    Text("SHA-384")
                }
            }.padding(.bottom, 2)
            TitleValue(localizedTitle: "Digest") {
                Text(data.digest.base64EncodedString())
                    .fixedwidth()
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
