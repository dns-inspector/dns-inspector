package main

import (
	"crypto/rand"
	"crypto/tls"
	"encoding/binary"
	"fmt"
	"net"
	"sync"
)

type tserverDNSOverTLS struct{}

func (s *tserverDNSOverTLS) Start(port uint16, ipv4 string, ipv6 string, servername string) error {
	chain, _, err := generateCertificateChain("DNSOverTLS", 1, port, ipv4, ipv6, servername, nil)
	if err != nil {
		return err
	}

	tlsConfig := &tls.Config{
		Certificates: []tls.Certificate{*chain},
		RootCAs:      rootCAPool,
		ServerName:   servername,
	}
	t4l, err := tls.Listen("tcp4", fmt.Sprintf("%s:%d", ipv4, port), tlsConfig)
	if err != nil {
		return err
	}
	t6l, err := tls.Listen("tcp6", fmt.Sprintf("[%s]:%d", ipv6, port), tlsConfig)
	if err != nil {
		return err
	}

	wg := &sync.WaitGroup{}
	wg.Add(1)
	var tlsErr error

	go func() {
		for {
			conn, err := t4l.Accept()
			if err != nil {
				tlsErr = err
				wg.Done()
				break
			}
			go s.Handle(conn)
		}
	}()
	go func() {
		for {
			conn, err := t6l.Accept()
			if err != nil {
				tlsErr = err
				wg.Done()
				break
			}
			go s.Handle(conn)
		}
	}()

	fmt.Printf("DNSTLS ready on %s:%d, [%s]:%d\n", ipv4, port, ipv6, port)
	wg.Wait()
	return tlsErr
}

func (s *tserverDNSOverTLS) Handle(conn net.Conn) {
	lenBuf := make([]byte, 2)
	if _, err := conn.Read(lenBuf); err != nil {
		conn.Close()
		return
	}

	length := binary.BigEndian.Uint16(lenBuf)

	dataBuf := make([]byte, length)
	if _, err := conn.Read(dataBuf); err != nil {
		conn.Close()
		return
	}

	testName := getDNSTestName(dataBuf)
	if testName == TestNameRandomData {
		data := make([]byte, 265)
		rand.Read(data)
		conn.Write(data)
		conn.Close()
		return
	}

	response, err := handleDNSQuery(dataBuf)
	if err != nil {
		conn.Close()
		return
	}

	var replyLength uint16

	if testName == TestNameLengthOver {
		replyLength = uint16(length + 32)
	} else if testName == TestNameLengthUnder {
		replyLength = uint16(length - 32)
	} else {
		replyLength = uint16(len(response))
	}

	lenBuf = make([]byte, 2)
	binary.BigEndian.PutUint16(lenBuf, replyLength)

	conn.Write(lenBuf)
	conn.Write(response)
	conn.Close()
}
