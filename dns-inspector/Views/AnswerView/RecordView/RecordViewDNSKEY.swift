import SwiftUI
import DNSKit

struct RecordViewDNSKEY: View {
    let data: DNSKEYRecordData

    var body: some View {
        VStack(alignment: .leading) {
            TitleValue(localizedTitle: "Key tag") {
                Text(String(data.keyTag))
            }.padding(.bottom, 2)
            if data.keySigningKey {
                TitleValue(localizedTitle: "Key Usage") {
                    Text(localized: "Key signing key")
                }.padding(.bottom, 2)
            } else if data.zoneKey {
                TitleValue(localizedTitle: "Key Usage") {
                    Text(localized: "Zone signing key")
                }.padding(.bottom, 2)
            }
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
            TitleValue(localizedTitle: "Public key") {
                Text(data.publicKey.base64EncodedString())
                    .fixedwidth()
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
