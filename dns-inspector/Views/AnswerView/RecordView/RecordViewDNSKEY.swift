// DNS Inspector
// Copyright (C) 2024 Ian Spence
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
