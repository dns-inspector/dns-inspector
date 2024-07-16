import Foundation

/// DNSSEC client
internal struct DNSSECClient {
    /// Authenticate that the message was signed with a fully valid chain, going up to the DNS root.
    /// - Parameters:
    ///   - message: The message to authenticate
    ///   - client: The DNS client to use for queries
    ///   - complete: Called with the result of this DNSSEC operation
    internal static func authenticateMessage(_ message: Message, client: IClient, complete: (DNSSECResult) -> Void) throws {
        var result = DNSSECResult()

        var oRrsigData: RRSIGRecordData?

        for answer in message.answers {
            if answer.recordType != .RRSIG {
                continue
            }

            guard let data = answer.data as? RRSIGRecordData else {
                printError("[\(#fileID):\(#line)] Invalid RRSIG data")
                throw DNSSECError.invalidResponse.error("Invalid RRSIG data")
            }

            oRrsigData = data
            break
        }

        guard let rrsigData = oRrsigData else {
            printError("[\(#fileID):\(#line)] No record signature included in message")
            throw DNSSECError.invalidResponse.error("No record signature included in message")
        }

        switch rrsigData.algorithm {
        case .RSA_SHA256, .RSA_SHA512, .ECDSAP256_SHA256, .ECDSAP384_SHA384:
            break
        default:
            printError("[\(#fileID):\(#line)] Unsupported or unknown algorithm")
            throw DNSSECError.unsupportedAlgorithm.error("Unsupported or unknown algorithm")
        }

        let resources: [DNSSECResource]
        do {
            resources = try DNSSECClient.getKeyChain(startingAt: rrsigData.signerName, client: client)
            if resources.count == 0 {
                printError("[\(#fileID):\(#line)] No signing keys found")
                throw DNSSECError.missingKeys.error("No signing keys found")
            }
        } catch {
            result.signatureError = error
            complete(result)
            return
        }

        result.resources = resources

        // Double check that the root KSK is what we expect
        guard let rootResource = resources.last else {
            printError("[\(#fileID):\(#line)] No signing keys found")
            throw DNSSECError.missingKeys.error("No signing keys found")
        }
        var foundRootKsk = false
        for rootKeyAnswer in rootResource.dnsKeys {
            guard let data = rootKeyAnswer.data as? DNSKEYRecordData else {
                continue
            }

            if !data.keySigningKey {
                continue
            }

            foundRootKsk = true
            if data.publicKey != DNSSECClient.trustedRootKsk() {
                printError("[\(#fileID):\(#line)] Untrusted root key signing key")
                printDebug("[\(#fileID):\(#line)] Ksk from response: \(data.publicKey.hexEncodedString())")
                printDebug("[\(#fileID):\(#line)] Trusted root ksk: \(DNSSECClient.trustedRootKsk().hexEncodedString())")
                result.chainError = DNSSECError.untrustedRootSigningKey.error("Untrusted root key signing key")
                complete(result)
                return
            }
        }
        if !foundRootKsk {
            printError("[\(#fileID):\(#line)] Unable to locate root key signing key")
            result.chainError = DNSSECError.untrustedRootSigningKey.error("Untrusted root key signing key")
            complete(result)
            return
        }

        // Starting at the furthest descdent zone:
        // - Verify the signature of the original message against its RR and the DNSKEY we fetched
        // - Verify the signature of the DNSKEY message
        // - Verify the DS record of each parent zoon, until the root
        // If all of the above tests pass, then we can attest full trust of the chain

        // Verify the signature of the original message against its RR and the DNSKEY we fetched
        do {
            var rrset: [Answer] = []
            var oRrsigAnswer: Answer?

            for answer in message.answers {
                if answer.recordType == .RRSIG {
                    oRrsigAnswer = answer
                    continue
                } else {
                    rrset.append(answer)
                }
            }

            guard let rrsigAnswer = oRrsigAnswer else {
                printError("[\(#fileID):\(#line)] No signature for associated resource record")
                result.signatureError = DNSSECError.noSignatures.error("No signature for associated resource record")
                complete(result)
                return
            }

            guard let rrsig = rrsigAnswer.data as? RRSIGRecordData else {
                printError("[\(#fileID):\(#line)] No signature for associated resource record")
                result.signatureError = DNSSECError.noSignatures.error("No signature for associated resource record")
                complete(result)
                return
            }

            // Find the matching key
            var oZsk: Answer?
            for dnskey in resources[0].dnsKeys {
                guard let key = dnskey.data as? DNSKEYRecordData else {
                    printError("[\(#fileID):\(#line)] Bad record data type on \(dnskey.description)")
                    continue
                }
                if key.keyTag == rrsig.keyTag {
                    oZsk = dnskey
                    break
                }
            }
            guard let zsk = oZsk else {
                printError("[\(#fileID):\(#line)] No key with tag \(rrsig.keyTag) found on zone \(resources[0].zone)")
                result.signatureError = DNSSECError.missingKeys.error("No matching key found")
                complete(result)
                return
            }

            do {
                try DNSSECClient.validateAnswers(rrset, signatureAnswer: rrsigAnswer, dnskeyAnswer: zsk)
            } catch {
                result.signatureError = error
                complete(result)
                return
            }

            result.signatureVerified = true
        }

        // Verify the signature of the DNSKEY message
        do {
            let keyAnswers = resources[0].dnsKeys
            let rrsigAnswer = resources[0].keySignature
            guard let rrsig = rrsigAnswer.data as? RRSIGRecordData else {
                printError("[\(#fileID):\(#line)] No signature for associated resource record")
                result.signatureError = DNSSECError.noSignatures.error("No signature for associated resource record")
                complete(result)
                return
            }

            // Find the matching key
            var oKsk: Answer?
            for dnskey in resources[0].dnsKeys {
                guard let key = dnskey.data as? DNSKEYRecordData else {
                    continue
                }
                if key.keyTag == rrsig.keyTag {
                    oKsk = dnskey
                    break
                }
            }
            guard let ksk = oKsk else {
                printError("[\(#fileID):\(#line)] No key with tag \(rrsig.keyTag) found on zone")
                result.signatureError = DNSSECError.missingKeys.error("No matching key found")
                complete(result)
                return
            }

            do {
                try DNSSECClient.validateAnswers(keyAnswers, signatureAnswer: rrsigAnswer, dnskeyAnswer: ksk)
            } catch {
                result.signatureError = error
                complete(result)
                return
            }
        }

        // Verify the DS record of each parent zone, until the root
        for i in 0...resources.count-2 { // -2 because the root doesn't have a DS
            guard let dsAnswer = resources[i].ds else {
                printError("[\(#fileID):\(#line)] Missing required DS record for zone \(resources[i].zone)")
                result.chainError = DNSSECError.noSignatures.error("Missing required DS record")
                complete(result)
                return
            }
            guard let ds = dsAnswer.data as? DSRecordData else {
                printError("[\(#fileID):\(#line)] Missing required DS record \(resources[i].zone)")
                result.chainError = DNSSECError.noSignatures.error("Missing required DS record")
                complete(result)
                return
            }

            // Check the ds digest
            do {
                var digestMatched = false
                for answer in resources[i].dnsKeys {
                    guard let dnskey = answer.data as? DNSKEYRecordData else {
                        continue
                    }
                    if ds.keyTag != dnskey.keyTag {
                        continue
                    }

                    guard let digest = try? dnskey.hashWithOwnerName(dsAnswer.name, digest: ds.digestType) else {
                        continue
                    }

                    if digest == ds.digest {
                        digestMatched = true
                        break
                    }
                }

                if !digestMatched {
                    printError("[\(#fileID):\(#line)] No matching DNSKEY found from DS digest")
                    result.chainError = DNSSECError.missingKeys.error("Unknown DNSKEY referenced in DS record")
                    complete(result)
                    return
                }
            }

            guard let rrsigAnswer = resources[i].dsSignature else {
                printError("[\(#fileID):\(#line)] Missing DS record signature")
                result.signatureError = DNSSECError.noSignatures.error("Missing DS record signature")
                complete(result)
                return
            }

            guard let rrsig = rrsigAnswer.data as? RRSIGRecordData else {
                printError("[\(#fileID):\(#line)] Missing DS record signature")
                result.signatureError = DNSSECError.noSignatures.error("Missing DS record signature")
                complete(result)
                return
            }

            // DS Records are signed by their parent zone's key
            var dnskeyAnswer: Answer?
            for answer in resources[i+1].dnsKeys {
                guard let dnskey = answer.data as? DNSKEYRecordData else {
                    continue
                }
                if dnskey.keyTag == rrsig.keyTag {
                    dnskeyAnswer = answer
                    break
                }
            }
            if dnskeyAnswer == nil {
                printError("[\(#fileID):\(#line)] No key with tag \(rrsig.keyTag) found on zone")
                result.chainError = DNSSECError.missingKeys.error("Missing DNSKEY for RRSIG")
                complete(result)
                return
            }

            do {
                try DNSSECClient.validateAnswers([dsAnswer], signatureAnswer: rrsigAnswer, dnskeyAnswer: dnskeyAnswer!)
            } catch {
                printError("[\(#fileID):\(#line)] RRSIG validation failure for DS record")
                result.chainError = error
                complete(result)
                return
            }
            result.chainTrusted = true
        }

        complete(result)
    }

    /// Get the chain of keys & signatures starting from the given name going up to the root zone
    /// - Parameters:
    ///   - name: The name to start from
    ///   - client: The client to use for performing queries
    /// - Returns: An array of DNSSEC resources for each zone
    /// - Throws: Will throw on any error getting the data or if any required data is missing
    internal static func getKeyChain(startingAt name: String, client: IClient) throws -> [DNSSECResource] {
        var names: [String] = []
        var nextName = name
        var questionsToSend = 0
        var questionsAnswered = 0
        while true {
            names.append(nextName)
            questionsToSend += 2 // DNSKEY + DS question per zone

            let nameParts = nextName.split(separator: ".")
            if nameParts.count == 0 || nameParts[0].count == 0 {
                break
            } else {
                nextName = nameParts.suffix(from: 1).joined(separator: ".")
                if nextName.count == 0 {
                    nextName = "."
                }
            }
        }

        var dnskeyErrors: [Int: Error] = [:]
        var dsErrors: [Int: Error] = [:]
        var dnskeyAnswers: [Int: [Answer]] = [:]
        var dsAnswers: [Int: [Answer]] = [:]

        let lock = NSObject()
        let sync = DispatchSemaphore(value: 0)

        // Get all the resource we need in parallel
        for i in 0...names.count-1 {
            // Get the DNSKEY for this zone
            let dnskeyQuestion = Question(name: names[i], recordType: .DNSKEY, recordClass: .IN)
            printDebug("[\(#fileID):\(#line)] Getting DNSKEY for \(names[i])")
            let message = Message(question: dnskeyQuestion, dnssecOK: true)
            client.send(message: message) { result in
                switch result {
                case .success(let reply):
                    if reply.responseCode != .NOERROR {
                        objc_sync_enter(lock)
                        printError("[\(#fileID):\(#line)] No DNSKEY record for zone \(names[i])")
                        dnskeyErrors[i] = Utils.MakeError("No DNSKEY record for zone \(names[i])")
                        objc_sync_exit(lock)
                        break
                    }

                    var hasDNSKEY = false
                    var hasRRSIG = false
                    for answer in reply.answers {
                        switch answer.recordType {
                        case .RRSIG:
                            hasRRSIG = true
                        case .DNSKEY:
                            hasDNSKEY = true
                        default:
                            break
                        }
                    }

                    objc_sync_enter(lock)
                    if !hasDNSKEY {
                        printError("[\(#fileID):\(#line)] No DNSKEY record for zone \(names[i])")
                        dnskeyErrors[i] = Utils.MakeError("No DNSKEY record for zone \(names[i])")
                    } else if !hasRRSIG {
                        printError("[\(#fileID):\(#line)] No RRSIG record for zone \(names[i])")
                        dnskeyErrors[i] = Utils.MakeError("No RRSIG record for zone \(names[i])")
                    } else {
                        printDebug("[\(#fileID):\(#line)] Fetched \(reply.answers.count) DNSKEYs for zone \(names[i])")
                        dnskeyAnswers[i] = reply.answers
                    }
                    objc_sync_exit(lock)
                case .failure(let error):
                    objc_sync_enter(lock)
                    printError("[\(#fileID):\(#line)] Error getting DNSKEY records for zone \(names[i])")
                    dnskeyErrors[i] = error
                    objc_sync_exit(lock)
                }

                objc_sync_enter(lock)
                questionsAnswered += 1
                if questionsAnswered >= questionsToSend {
                    sync.signal()
                }
                objc_sync_exit(lock)
            }

            // Root zone does not have a DS
            if names[i].count == 1 && names[i] == "." {
                objc_sync_enter(lock)
                questionsAnswered += 1
                if questionsAnswered >= questionsToSend {
                    sync.signal()
                }
                objc_sync_exit(lock)
                continue
            }

            // Get the DS record for this zone
            let dsQuestion = Question(name: names[i], recordType: .DS, recordClass: .IN)
            printDebug("[\(#fileID):\(#line)] Getting DS for \(names[i])")
            let dsMessage = Message(question: dsQuestion, dnssecOK: true)
            client.send(message: dsMessage) { result in
                switch result {
                case .success(let reply):
                    if reply.responseCode != .NOERROR {
                        objc_sync_enter(lock)
                        printError("[\(#fileID):\(#line)] No DS record for zone \(names[i])")
                        dnskeyErrors[i] = Utils.MakeError("No DS record for zone \(names[i])")
                        objc_sync_exit(lock)
                        break
                    }

                    var hasDS = false
                    var hasRRSIG = false
                    for answer in reply.answers {
                        switch answer.recordType {
                        case .RRSIG:
                            hasRRSIG = true
                        case .DS:
                            hasDS = true
                        default:
                            break
                        }
                    }

                    objc_sync_enter(lock)
                    if !hasDS {
                        printError("[\(#fileID):\(#line)] No DS record for zone \(names[i])")
                        dsErrors[i] = Utils.MakeError("No DS record for zone \(names[i])")
                    } else if !hasRRSIG {
                        printError("[\(#fileID):\(#line)] No RRSIG record for zone \(names[i])")
                        dsErrors[i] = Utils.MakeError("No RRSIG record for zone \(names[i])")
                    } else {
                        printDebug("[\(#fileID):\(#line)] Fetched \(reply.answers.count) DSs for zone \(names[i])")
                        dsAnswers[i] = reply.answers
                    }
                    objc_sync_exit(lock)
                case .failure(let error):
                    objc_sync_enter(lock)
                    printError("[\(#fileID):\(#line)] Error getting DS records for zone \(names[i])")
                    dnskeyErrors[i] = error
                    objc_sync_exit(lock)
                }

                objc_sync_enter(lock)
                questionsAnswered += 1
                if questionsAnswered >= questionsToSend {
                    sync.signal()
                }
                objc_sync_exit(lock)
            }
        }

        _ = sync.wait(timeout: .now().advanced(by: DispatchTimeInterval.seconds(10)))

        if questionsAnswered != questionsToSend {
            printError("[\(#fileID):\(#line)] Unable to query for all records")
            printError("[\(#fileID):\(#line)] One or more DNSKEY or DS records or their associated signatures were not found")
            throw DNSSECError.missingKeys.error("One or more DNSKEY or DS records or their associated signatures were not found")
        }

        var resources: [DNSSECResource] = []

        // Sort through the answers and split up the DNSKEY, the RRSIG for the DNSKEY, and the same for the DS
        for i in 0...names.count-1 {
            let name = names[i]
            var keys: [Answer] = []
            var oKeySig: Answer?
            for answer in dnskeyAnswers[i] ?? [] {
                if answer.recordType == .DNSKEY {
                    keys.append(answer)
                } else if answer.recordType == .RRSIG {
                    oKeySig = answer
                }
            }
            guard let keySig = oKeySig else {
                printError("[\(#fileID):\(#line)] Missing RRSIG for DNSKEY \(name)")
                throw DNSSECError.missingKeys.error("Missing RRSIG for DNSKEY \(name)")
            }

            var ds: Answer?
            var dsSig: Answer?
            if name.count > 1 {
                for answer in dsAnswers[i] ?? [] {
                    if answer.recordType == .DS {
                        ds = answer
                    } else if answer.recordType == .RRSIG {
                        dsSig = answer
                    }
                }
                if dsSig == nil {
                    printError("[\(#fileID):\(#line)] Missing RRSIG for DS \(name)")
                    throw DNSSECError.missingKeys.error("Missing RRSIG for DS \(name)")
                }
            }

            resources.append(DNSSECResource(zone: name, dnsKeys: keys, keySignature: keySig, ds: ds, dsSignature: dsSig))
        }

        printInformation("[\(#fileID):\(#line)] Fetched DNSKEY and DS for \(names.count) zones")
        return resources
    }

    /// Validate the set of DNS Answers against the signature and key
    /// - Parameters:
    ///   - answers: The set of answers, exclusing the RRSIG answer
    ///   - signatureAnswer: The RRSIG answer associated for the set of answers
    ///   - dnskeyAnswer: The DNSKEY used to sign the RRSIG
    /// - Throws: Will thow on validation error. If no error is thrown then the answers validated successfully.
    internal static func validateAnswers(_ answers: [Answer], signatureAnswer: Answer, dnskeyAnswer: Answer) throws {
        if answers.count == 0 {
            printError("[\(#fileID):\(#line)] Empty rrset")
            throw DNSSECError.invalidResponse.error("Empty rrset")
        }

        // All answers must have the same name, type, and class
        for i in 0...answers.count-1 {
            if answers[i].name != answers[0].name {
                printError("[\(#fileID):\(#line)] Mismatches names in rrset")
                throw DNSSECError.invalidResponse.error("Mismatches names in rrset")
            }
            if answers[i].recordType != answers[0].recordType {
                printError("[\(#fileID):\(#line)] Mismatches types in rrset")
                throw DNSSECError.invalidResponse.error("Mismatches types in rrset")
            }
            if answers[i].recordClass != answers[0].recordClass {
                printError("[\(#fileID):\(#line)] Mismatches classes in rrset")
                throw DNSSECError.invalidResponse.error("Mismatches classes in rrset")
            }
        }

        guard let rrsig = signatureAnswer.data as? RRSIGRecordData else {
            printError("[\(#fileID):\(#line)] Incorrect RRSIG record data")
            throw DNSSECError.noSignatures.error("Incorrect RRSIG record data")
        }
        guard let dnskey = dnskeyAnswer.data as? DNSKEYRecordData else {
            printError("[\(#fileID):\(#line)] Incorrect DNSKEY record data")
            throw DNSSECError.noSignatures.error("Incorrect DNSKEY record data")
        }

        if rrsig.keyTag != dnskey.keyTag {
            printError("[\(#fileID):\(#line)] Mismatched keytag from signature")
            throw DNSSECError.badSigningKey.error("Mismatched keytag from signature")
        }
        if signatureAnswer.recordClass != dnskeyAnswer.recordClass {
            printError("[\(#fileID):\(#line)] Mismatched record class from signature")
            throw DNSSECError.badSigningKey.error("Mismatched record class from signature")
        }
        if rrsig.algorithm != dnskey.algorithm {
            printError("[\(#fileID):\(#line)] Mismatched algorithm from signature")
            throw DNSSECError.badSigningKey.error("Mismatched algorithm from signature")
        }
        if rrsig.signerName.lowercased() != dnskeyAnswer.name.lowercased() {
            printError("[\(#fileID):\(#line)] Mismatched signer name from signature")
            throw DNSSECError.badSigningKey.error("Mismatched signer name from signature")
        }
        if dnskey.keyProtocol != 3 {
            printError("[\(#fileID):\(#line)] Unknown key protocol")
            throw DNSSECError.badSigningKey.error("Unknown key protocol")
        }
        if !dnskey.zoneKey {
            printError("[\(#fileID):\(#line)] Improper zone key usage")
            throw DNSSECError.badSigningKey.error("Improper zone key usage")
        }
        if dnskey.revoked {
            printError("[\(#fileID):\(#line)] Key is revoked")
            throw DNSSECError.badSigningKey.error("Key is revoked")
        }
        if answers[0].recordClass != signatureAnswer.recordClass {
            printError("[\(#fileID):\(#line)] Mismatched record class from signature")
            throw DNSSECError.badSigningKey.error("Mismatched record class from signature")
        }
        if answers[0].recordType != rrsig.typeCovered {
            printError("[\(#fileID):\(#line)] Mismatched record type from signature")
            throw DNSSECError.badSigningKey.error("Mismatched record type from signature")
        }

        guard var signedData: Data = try? Data(rrsig.signedData()) else {
            printError("[\(#fileID):\(#line)] Unable to determine signed data from signature")
            throw DNSSECError.invalidResponse.error("Unable to determine signed data from signature")
        }

        for answer in answers.sorted() {
            do {
                let rawSignatureData = try answer.rawSignatureData(rrsigAnswer: signatureAnswer)
                signedData.append(rawSignatureData)
            } catch {
                printError("[\(#fileID):\(#line)] Unable to determine signed data from signature")
                throw DNSSECError.invalidResponse.error("Unable to determine signed data from signature")
            }
        }

        let publicKey: SecKey
        do {
            publicKey = try dnskey.parsePublicKey()
        } catch {
            printError("[\(#fileID):\(#line)] Invalid public key: \(error.localizedDescription)")
            throw DNSSECError.badSigningKey.error("Invalid public key: \(error.localizedDescription)")
        }

        let algorithm: SecKeyAlgorithm
        switch rrsig.algorithm {
        case .RSA_SHA1:
            printError("[\(#fileID):\(#line)] SHA-1 is unsupported")
            throw DNSSECError.unsupportedAlgorithm.error("SHA-1 is unsupported")
        case .RSA_SHA256:
            algorithm = .rsaSignatureMessagePKCS1v15SHA256
        case .RSA_SHA512:
            algorithm = .rsaSignatureMessagePKCS1v15SHA512
        case .ECDSAP256_SHA256:
            algorithm = .ecdsaSignatureMessageX962SHA256
        case .ECDSAP384_SHA384:
            algorithm = .ecdsaSignatureMessageX962SHA384
        }

        let signature = rrsig.signatureForCrypto()

        var verifyError: Unmanaged<CFError>?
        let verified = SecKeyVerifySignature(publicKey, algorithm, signedData as CFData, signature as CFData, &verifyError)

        if !verified {
            printError("[\(#fileID):\(#line)] Signature validation failed")
            throw DNSSECError.signatureFailed.error("Signature validation failed")
        }
    }
}
