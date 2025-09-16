// DNS Inspector
// Copyright (C) Ian Spence and other DNS Inspector Contributors
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

import Foundation
import DNSKit

// swiftlint:disable cyclomatic_complexity
@MainActor
func localizedErrorDetails(_ error: any Error) -> String {
    if let error = error as? DNSKitError {
        switch error {
        case .connectionError(let details):
            return Localize.connectionerrordetails(details: details.localizedDescription)
        case .timedOut:
            return Localize.timedout()
        case .unexpectedResponse(let details):
            return Localize.unexpectedresponsedetails(details: details.localizedDescription)
        case .emptyResponse:
            return Localize.emptyresponse()
        case .invalidData(let details):
            return Localize.invaliddatadetails(details: details)
        case .missingData(let details):
            return Localize.missingdatadetails(details: details)
        case .excessiveResponseSize:
            return Localize.excessiveresponsesize()
        case .unsupportedAlgorithm:
            return Localize.unsupportedalgorithm()
        case .invalidUrl:
            return Localize.invalidurl()
        case .httpError(let details):
            return Localize.httpcode(code: String(describing: details))
        case .invalidContentType(let details):
            return Localize.invalidcontenttypedetails(details: details)
        case .internalError:
            // Should never be seen
            return ""
        }
    } else if let error = error as? DNSSECError {
        switch error {
        case .noSignatures(let details):
            return Localize.nosignaturesdetails(details: details)
        case .unsupportedAlgorithm:
            return Localize.unsupportedalgorithm()
        case .missingKeys(let details):
            return Localize.missingkeysdetails(details: details)
        case .untrustedRootSigningKey:
            return Localize.untrustedrootsigningkey()
        case .signatureFailed:
            return Localize.signaturefailed()
        case .invalidResponse(let details):
            return Localize.invalidresponsedetails(details: details)
        case .badSigningKey(let details):
            return Localize.badsigningkeydetails(details: details)
        case .internalError(let details):
            return Localize.internalerrordetails(details: details)
        }
    } else if let error = error as? WHOISError {
        switch error {
        case .connectionError(let details):
            return Localize.connectionerrordetails(details: details.localizedDescription)
        case .timedOut:
            return Localize.timedout()
        case .whoisNotSupported:
            return Localize.whoisnotsupportedonthisdomain()
        case .tooManyRedirects:
            return Localize.toomanyredirects()
        }
    }

    return error.localizedDescription
}
// swiftlint:enable cyclomatic_complexity
