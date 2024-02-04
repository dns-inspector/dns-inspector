package main

import (
	"fmt"
	"net"
	"sync"
)

type tserverDNSUDP struct{}

func (s *tserverDNSUDP) Start(port uint16, ipv4 string, ipv6 string, servername string) error {
	t4l, err := net.ListenPacket("udp4", fmt.Sprintf("%s:%d", ipv4, port))
	if err != nil {
		return err
	}
	t6l, err := net.ListenPacket("udp6", fmt.Sprintf("[%s]:%d", ipv6, port))
	if err != nil {
		return err
	}

	wg := &sync.WaitGroup{}
	wg.Add(1)
	var dnsError error

	go func() {
		dataBuf := make([]byte, 512)
		length, addr, err := t4l.ReadFrom(dataBuf)
		if err != nil {
			dnsError = err
			wg.Done()
			return
		}
		go s.Handle(dataBuf[0:length], t4l, addr)
	}()
	go func() {
		dataBuf := make([]byte, 512)
		length, addr, err := t6l.ReadFrom(dataBuf)
		if err != nil {
			dnsError = err
			wg.Done()
			return
		}
		go s.Handle(dataBuf[0:length], t6l, addr)
	}()

	fmt.Printf("DNSUDP ready on %s:%d, [%s]:%d\n", ipv4, port, ipv6, port)
	wg.Wait()
	return dnsError
}

func (s *tserverDNSUDP) Handle(message []byte, conn net.PacketConn, addr net.Addr) {
	response, err := handleDNSQuery(message)
	if err != nil {
		return
	}

	conn.WriteTo(response, addr)
}
