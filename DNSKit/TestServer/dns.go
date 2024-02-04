package main

import (
	"golang.org/x/net/dns/dnsmessage"
)

// DNS names used to influence what type of test response is returned
const (
	TestNameControl     = "control.example.com."
	TestNameRandomData  = "random.example.com."
	TestNameLengthOver  = "length.over.example.com."
	TestNameLengthUnder = "length.under.example.com."
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
