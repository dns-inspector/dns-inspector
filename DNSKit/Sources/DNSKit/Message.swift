import Foundation

/// Describes a DNS message
public struct Message {
    /// The message ID number
    public let idNumber: UInt16
    /// If recursion was desired
    public let recursionDesired: Bool
    /// If the message is truncated
    public let truncated: Bool
    /// If this is an authoritative answer
    public let authoritativeAnswer: Bool
    /// The message operation code
    public let operationCode: OperationCode
    /// If this is a request (false) or response (true)
    public let isResponse: Bool
    /// The response code
    public let responseCode: ResponseCode
    /// Message questions
    public let questions: [Question]
    /// Message answers
    public let answers: [Answer]
    /// If DNSSEC is ok
    public let dnssecOK: Bool
    /// The amount of time (in nanoseconds) it took to recieve this message in response to our question
    public let duration: UInt64

    internal init(idNumber: UInt16 = UInt16.random(), question: Question, dnssecOK: Bool) {
        self.idNumber = idNumber
        self.recursionDesired = false
        self.truncated = false
        self.authoritativeAnswer = false
        self.operationCode = .Query
        self.isResponse = false
        self.responseCode = .NOERROR
        self.questions = [question]
        self.answers = []
        self.dnssecOK = dnssecOK
        self.duration = 0
    }

    internal init(messageData: Data, elapsed: UInt64) throws {
        if messageData.count < 12 {
            printError("[\(#fileID):\(#line)] Invalid DNS message: too short \(messageData.count)B")
            throw Utils.MakeError("Invalid DNS message: too short")
        }

        // Read the header
        let header = try MessageHeader(messageData: messageData)
        self.idNumber = header.idNumber
        self.recursionDesired = header.recursionDesired
        self.truncated = header.truncated
        self.authoritativeAnswer = header.authoritativeAnswer
        guard let opCode = OperationCode(rawValue: Int(header.operationCode)) else {
            printError("[\(#fileID):\(#line)] Invalid DNS message: unknown operation code \(header.operationCode)")
            throw Utils.MakeError("Invalid DNS message: unknown operation code")
        }
        self.operationCode = opCode
        self.isResponse = header.isResponse
        guard let rCode = ResponseCode(rawValue: Int(header.responseCode)) else {
            printError("[\(#fileID):\(#line)] Invalid DNS message: unknown response code \(header.responseCode)")
            throw Utils.MakeError("Invalid DNS message: unknown response code")
        }
        self.responseCode = rCode

        if header.questionCount == 0 {
            printError("[\(#fileID):\(#line)] Invalid DNS message: no questions")
            throw Utils.MakeError("Invalid DNS message: no questions")
        }

        let (questions, answerStartOffset) = try Message.readQuestions(messageData: messageData, expectedQuestionCount: header.questionCount)
        self.questions = questions

        let (answers, _) = try Message.readAnswers(messageData: messageData, expectedAnswerCount: header.answerCount, startOffset: answerStartOffset)
        self.answers = answers

        self.dnssecOK = false
        self.duration = elapsed
    }

    internal static func readQuestions(messageData: Data, expectedQuestionCount: UInt16) throws -> ([Question], Int) {
        var questions: [Question] = []
        var questionsRead = 0
        var questionStartOffset = 12
        while questionsRead < expectedQuestionCount {
            let (name, dataOffset) = try Name.readName(messageData, startOffset: questionStartOffset)

            let (recordTypeRaw, recordClassRaw) = messageData.withUnsafeBytes { data in
                let t = data.loadUnaligned(fromByteOffset: dataOffset, as: UInt16.self).bigEndian
                let c = data.loadUnaligned(fromByteOffset: dataOffset+2, as: UInt16.self).bigEndian
                return (t, c)
            }

            guard let recordType = RecordType(rawValue: recordTypeRaw) else {
                printError("[\(#fileID):\(#line)] Invalid DNS message: unknown record type in question at index \(questionsRead): \(recordTypeRaw)")
                throw Utils.MakeError("Invalid DNS message: unknown record type")
            }
            guard let recordClass = RecordClass(rawValue: recordClassRaw) else {
                printError("[\(#fileID):\(#line)] Invalid DNS message: unknown record class in question at index \(questionsRead): \(recordClassRaw)")
                throw Utils.MakeError("Invalid DNS message: unknown record class")
            }

            questions.append(Question(name: name, recordType: recordType, recordClass: recordClass))
            questionsRead += 1
            questionStartOffset = dataOffset+4
        }

        return (questions, questionStartOffset)
    }

    internal static func readAnswers(messageData: Data, expectedAnswerCount: UInt16, startOffset: Int) throws -> ([Answer], Int) {
        var answers: [Answer] = []
        var answersRead = 0
        var answerStartOffset = startOffset
        while answersRead < expectedAnswerCount {
            let (name, dataOffset) = try Name.readName(messageData, startOffset: answerStartOffset)

            let (recordTypeRaw, recordClassRaw, ttl, dataLength) = messageData.withUnsafeBytes { data in
                var offset = dataOffset
                let ty = data.loadUnaligned(fromByteOffset: offset, as: UInt16.self).bigEndian
                offset += 2
                let cl = data.loadUnaligned(fromByteOffset: offset, as: UInt16.self).bigEndian
                offset += 2
                let tt = data.loadUnaligned(fromByteOffset: offset, as: UInt32.self).bigEndian
                offset += 4
                let dl = data.loadUnaligned(fromByteOffset: offset, as: UInt16.self).bigEndian
                return (ty, cl, tt, dl)
            }
            guard let recordType = RecordType(rawValue: recordTypeRaw) else {
                printError("[\(#fileID):\(#line)] Invalid DNS message: unknown record type in answer at index \(answersRead): \(recordTypeRaw)")
                throw Utils.MakeError("Invalid DNS message: unknown record type")
            }
            guard let recordClass = RecordClass(rawValue: recordClassRaw) else {
                printError("[\(#fileID):\(#line)] Invalid DNS message: unknown record class in answer at index \(answersRead): \(recordClassRaw)")
                throw Utils.MakeError("Invalid DNS message: unknown record class")
            }
            if dataLength > messageData.count {
                printError("[\(#fileID):\(#line)] Invalid DNS message: data length (\(dataLength)B) of answer at index \(answersRead) exceeds message size \(messageData.count)B")
                throw Utils.MakeError("Invalid DNS message: data length exceeds actual size")
            }

            let valueStartOffset = dataOffset+10
            let value = messageData.subdata(in: valueStartOffset..<valueStartOffset+Int(dataLength))
            if value.count != dataLength {
                printError("[\(#fileID):\(#line)] Invalid DNS message: data length \(dataLength) must match record data size \(value.count)")
                throw Utils.MakeError("Invalid DNS message: data length must match record data size")
            }
            answerStartOffset = valueStartOffset+Int(dataLength)

            var recordData: RecordData?
            do {
                switch recordType {
                case .A:
                    recordData = try ARecordData(ipAddress: value)
                case .NS:
                    recordData = try NSRecordData(messageData: messageData, startOffset: valueStartOffset)
                case .CNAME:
                    recordData = try CNAMERecordData(messageData: messageData, startOffset: valueStartOffset)
                case .SOA:
                    recordData = try SOARecordData(messageData: messageData, startOffset: valueStartOffset)
                case .AAAA:
                    recordData = try AAAARecordData(ipAddress: value)
                case .SRV:
                    recordData = try SRVRecordData(messageData: messageData, startOffset: valueStartOffset)
                case .TXT:
                    recordData = try TXTRecordData(recordData: value)
                case .MX:
                    recordData = try MXRecordData(messageData: messageData, startOffset: valueStartOffset)
                case .PTR:
                    recordData = try PTRRecordData(messageData: messageData, startOffset: valueStartOffset)
                case .DS:
                    recordData = try DSRecordData(recordData: value)
                case .RRSIG:
                    recordData = try RRSIGRecordData(recordData: value)
                case .DNSKEY:
                    recordData = try DNSKEYRecordData(recordData: value)
                }
            } catch {
                printError("[\(#fileID):\(#line)] Error serlizing record data: \(error)")
                recordData = ErrorRecordData(error: error)
            }

            guard let rData = recordData else {
                answersRead += 1
                continue
            }

            answers.append(Answer(name: name, recordType: recordType, recordClass: recordClass, ttlSeconds: ttl, dataLength: dataLength, data: rData, recordData: value))
            answersRead += 1
        }

        return (answers, answerStartOffset)
    }

    internal func data() throws -> Data {
        var request = Data()

        withUnsafePointer(to: self.idNumber.bigEndian) { idn in
            request.append(Data(bytes: idn, count: 2))
        }

        let flags: UInt16 = 0x0120
        withUnsafePointer(to: flags.bigEndian) { f in
            request.append(Data(bytes: f, count: 2))
        }

        let questionCount = UInt16(self.questions.count).bigEndian
        withUnsafePointer(to: questionCount) { qcount in
            request.append(Data(bytes: qcount, count: 2))
        }
        let answerCount = UInt16(self.answers.count).bigEndian
        withUnsafePointer(to: answerCount) { acount in
            request.append(Data(bytes: acount, count: 2))
        }
        let nameserverCount = UInt16(0).bigEndian
        withUnsafePointer(to: nameserverCount) { nscount in
            request.append(Data(bytes: nscount, count: 2))
        }
        let additionalCount = UInt16(1).bigEndian
        withUnsafePointer(to: additionalCount) { acount in
            request.append(Data(bytes: acount, count: 2))
        }

        for question in questions {
            let data = try question.data()
            request.append(data)
        }

        // We always pass an EDNS OPT message, even if we're not using DNSSEC
        // This value is the same for all requests, so we don't have to dynamically generate it
        //
        // 00 .... .... .. .. .... .... = name <root>
        // .. 0029 .... .. .. .... .... = type OPT (41)
        // .. .... 1000 .. .. .... .... = UDP payload size 4096
        // .. .... .... 00 .. .... .... = higher bits in extended RCODE
        // .. .... .... .. 00 .... .... = EDNS version 0
        // .. .... .... .. .. 8000 .... = DNSSEC OK (if DNSSEC was requsted, otherwise 0x0000)
        // .. .... .... .. .. .... 0000 = Data length 0
        request.append(Data([0x00, 0x00, 0x29, 0x10, 0x00, 0x00, 0x00, (self.dnssecOK ? 0x80 : 0x00), 0x00, 0x00, 0x00]))

        return request
    }
}

internal struct MessageHeader {
    let idNumber: UInt16
    let recursionDesired: Bool
    let truncated: Bool
    let authoritativeAnswer: Bool
    let operationCode: UInt8
    let isResponse: Bool
    let responseCode: UInt8
    let checkingDisabled: Bool
    let authenticatedData: Bool
    let recursionAvailable: Bool
    let questionCount: UInt16
    let answerCount: UInt16
    let nameserverCount: UInt16
    let additionalCount: UInt16

    init(messageData: Data) throws {
        if messageData.count < 12 {
            printError("[\(#fileID):\(#line)] Invalid DNS message: too short \(messageData.count)B")
            throw Utils.MakeError("Invalid DNS message: too short")
        }

        let (id, flags1, flags2, questionCount, answerCount, nameserverCount, additionalCount) = messageData.withUnsafeBytes {
            let id = $0.loadUnaligned(fromByteOffset: 0, as: UInt16.self).bigEndian
            let flags1 = $0.loadUnaligned(fromByteOffset: 2, as: UInt8.self).bigEndian
            let flags2 = $0.loadUnaligned(fromByteOffset: 3, as: UInt8.self).bigEndian
            let qCount = $0.loadUnaligned(fromByteOffset: 4, as: UInt16.self).bigEndian
            let aCount = $0.loadUnaligned(fromByteOffset: 6, as: UInt16.self).bigEndian
            let nCount = $0.loadUnaligned(fromByteOffset: 8, as: UInt16.self).bigEndian
            let mCount = $0.loadUnaligned(fromByteOffset: 10, as: UInt16.self).bigEndian
            return (id, flags1, flags2, qCount, aCount, nCount, mCount)
        }

        let isResponse = 0b10000000 & flags1 == 0b10000000
        let opCode: UInt8 = flags1 & 0b10000111 >> 3
        let authoritativeAnswer = 0b00000100 & flags1 == 0b00000100
        let truncated = 0b00000010 & flags1 == 0b00000010
        let recursionDesired = 0b00000001 & flags1 == 0b00000001
        let recursionAvailable = 0b10000000 & flags2 == 0b10000000
        let authenticatedData = 0b00100000 & flags2 == 0b00100000
        let checkingDisabled = 0b00010000 & flags2 == 0b00010000
        let responseCode: UInt8 = flags2 & 0b00001111

        self.idNumber = id
        self.isResponse = isResponse
        self.operationCode = opCode
        self.authoritativeAnswer = authoritativeAnswer
        self.truncated = truncated
        self.recursionDesired = recursionDesired
        self.recursionAvailable = recursionAvailable
        self.authenticatedData = authenticatedData
        self.checkingDisabled = checkingDisabled
        self.responseCode = responseCode
        self.questionCount = questionCount
        self.answerCount = answerCount
        self.nameserverCount = nameserverCount
        self.additionalCount = additionalCount
    }
}
