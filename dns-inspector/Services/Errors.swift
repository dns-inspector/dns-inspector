// DNS Inspector
// Copyright (C) 2025 Ian Spence
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
            return Localize("Connection error: {details}", args: [details.localizedDescription])
        case .timedOut:
            return Localize("Timed out")
        case .unexpectedResponse(let details):
            return Localize("Unexpected response: {details}", args: [details.localizedDescription])
        case .emptyResponse:
            return Localize("Empty response")
        case .invalidData(let details):
            return Localize("Invalid data: {details}", args: [details])
        case .missingData(let details):
            return Localize("Missing data: {details}", args: [details])
        case .excessiveResponseSize:
            return Localize("Excessive response size")
        case .unsupportedAlgorithm:
            return Localize("Unsupported algorithm")
        case .invalidUrl:
            return Localize("Invalid URL")
        case .httpError(let details):
            return Localize("HTTP {code}", args: ["\(details)"])
        case .invalidContentType(let details):
            return Localize("Invalid content type: {details}", args: [details])
        }
    } else if let error = error as? DNSSECError {
        switch error {
        case .noSignatures(let details):
            return Localize("No signatures: {details}", args: [details])
        case .unsupportedAlgorithm:
            return Localize("Unsupported algorithm")
        case .missingKeys(let details):
            return Localize("Missing keys: {details}", args: [details])
        case .untrustedRootSigningKey:
            return Localize("Untrusted root signing key")
        case .signatureFailed:
            return Localize("Signature failed")
        case .invalidResponse(let details):
            return Localize("Invalid response: {details}", args: [details])
        case .badSigningKey(let details):
            return Localize("Bad signing key: {details}", args: [details])
        case .internalError(let details):
            return Localize("Internal error: {details}", args: [details])
        }
    } else if let error = error as? WHOISError {
        switch error {
        case .connectionError(let details):
            return Localize("Connection error: {details}", args: [details.localizedDescription])
        case .timedOut:
            return Localize("Timed out")
        case .whoisNotSupported:
            return Localize("WHOIS not supported on this domain")
        case .tooManyRedirects:
            return Localize("Too many redirects")
        }
    }

    return error.localizedDescription
}
// swiftlint:enable cyclomatic_complexity
