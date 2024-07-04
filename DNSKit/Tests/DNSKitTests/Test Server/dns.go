package main

import (
	"golang.org/x/net/dns/dnsmessage"
)

// DNS names used to influence what type of test response is returned
const (
	TestNameControl        = "control.example.com."
	TestNameRandomData     = "random.example.com."
	TestNameLengthOver     = "length.over.example.com."
	TestNameLengthUnder    = "length.under.example.com."
	TestInvalidIPv4Address = "invalid.ipv4.example.com."
)

func getDNSTestName(in []byte) string {
	p := dnsmessage.Parser{}
	if _, err := p.Start(in); err != nil {
		return TestNameControl
	}

	questions, err := p.AllQuestions()
	if err != nil {
		return TestNameControl
	}

	if len(questions) != 1 {
		return TestNameControl
	}

	switch questions[0].Name.String() {
	case TestNameControl:
		return TestNameControl
	case TestNameRandomData:
		return TestNameRandomData
	case TestNameLengthOver:
		return TestNameLengthOver
	case TestNameLengthUnder:
		return TestNameLengthUnder
	case TestInvalidIPv4Address:
		return TestInvalidIPv4Address
	}

	return TestNameControl
}

func handleDNSQuery(in []byte) ([]byte, error) {
	p := dnsmessage.Parser{}
	header, err := p.Start(in)
	if err != nil {
		return nil, err
	}

	questions, err := p.AllQuestions()
	if err != nil {
		return nil, err
	}

	var replyBuf []byte
	header.Response = true
	header.RCode = dnsmessage.RCodeSuccess
	replyBuilder := dnsmessage.NewBuilder(replyBuf, header)
	replyBuilder.EnableCompression()
	replyBuilder.StartQuestions()
	for _, question := range questions {
		replyBuilder.Question(question)
	}

	replyBuilder.StartAnswers()

	switch questions[0].Type {
	case dnsmessage.TypeA:
		if questions[0].Name.String() == TestInvalidIPv4Address {
			// Forge a custom DNS reply with an invalid IPv4 address (5 bytes)
			reply := []byte{}
			// copy the ID
			reply = append(reply, in[0:2]...)
			// a DNS A reply for 'invalid.ipv4.example.com.'
			reply = append(reply, []byte{0x81, 0x20, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x07, 0x69, 0x6E, 0x76, 0x61, 0x6C, 0x69, 0x64, 0x04, 0x69, 0x70, 0x76, 0x34, 0x07, 0x65, 0x78, 0x61, 0x6D, 0x70, 0x6C, 0x65, 0x03, 0x63, 0x6F, 0x6D, 0x00, 0x00, 0x01, 0x00, 0x01, 0xC0, 0x0C, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00}...)
			// 5 byte data length + "127.0.0.0.1"
			reply = append(reply, []byte{0x05, 0x7f, 0x00, 0x00, 0x00, 0x01}...)

			return reply, nil
		}

		header, body := dnsAResource(questions[0].Name)
		replyBuilder.AResource(header, body)
	case dnsmessage.TypeNS:
		header, body := dnsNSResource(questions[0].Name)
		replyBuilder.NSResource(header, body)
	case dnsmessage.TypeAAAA:
		header, body := dnsAAAAResource(questions[0].Name)
		replyBuilder.AAAAResource(header, body)
	default:
		header.RCode = dnsmessage.RCodeNameError
	}

	response, err := replyBuilder.Finish()
	if err != nil {
		return nil, err
	}

	return response, nil
}

func dnsAResource(name dnsmessage.Name) (dnsmessage.ResourceHeader, dnsmessage.AResource) {
	return dnsmessage.ResourceHeader{
		Name:  name,
		Type:  dnsmessage.TypeA,
		Class: dnsmessage.ClassINET,
	}, dnsmessage.AResource{A: [4]byte{127, 0, 0, 1}}
}

func dnsNSResource(name dnsmessage.Name) (dnsmessage.ResourceHeader, dnsmessage.NSResource) {
	return dnsmessage.ResourceHeader{
		Name:  name,
		Type:  dnsmessage.TypeNS,
		Class: dnsmessage.ClassINET,
	}, dnsmessage.NSResource{NS: dnsmessage.MustNewName("example.com")}
}

func dnsAAAAResource(name dnsmessage.Name) (dnsmessage.ResourceHeader, dnsmessage.AAAAResource) {
	return dnsmessage.ResourceHeader{
		Name:  name,
		Type:  dnsmessage.TypeAAAA,
		Class: dnsmessage.ClassINET,
	}, dnsmessage.AAAAResource{AAAA: [16]byte{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}}
}
