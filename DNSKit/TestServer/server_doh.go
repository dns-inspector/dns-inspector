package main

import (
	"crypto/tls"
	"encoding/base64"
	"fmt"
	"log"
	"net/http"
	"sync"
)

type tserverDNSOverHTTPS struct{}

func (s *tserverDNSOverHTTPS) Start(port uint16, ipv4 string, ipv6 string, servername string) error {
	chain, _, err := generateCertificateChain("DNSOverHTTPS", 1, port, ipv4, ipv6, servername, nil)
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
	var httpError error

	go func() {
		if err := http.Serve(t4l, s); err != nil {
			httpError = err
		}
		wg.Done()
	}()
	go func() {
		if err := http.Serve(t6l, s); err != nil {
			httpError = err
		}
		wg.Done()
	}()

	fmt.Printf("DNSHTTPS ready on %s:%d, [%s]:%d\n", ipv4, port, ipv6, port)
	wg.Wait()
	return httpError
}

func (s *tserverDNSOverHTTPS) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/dns-query" {
		rw.WriteHeader(404)
		return
	}

	base64Message := r.URL.Query().Get("dns")
	if base64Message == "" {
		rw.WriteHeader(400)
		log.Printf("[DNSOverHTTPS] Missing dns query")
		return
	}

	message, err := base64.RawURLEncoding.DecodeString(base64Message)
	if err != nil {
		rw.WriteHeader(400)
		log.Printf("[DNSOverHTTPS] Error decoding dns query base64: %s", err.Error())
		return
	}

	response, err := handleDNSQuery(message)
	if err != nil {
		rw.WriteHeader(400)
		log.Printf("[DNSOverHTTPS] Error handling DNS query: %s", err.Error())
		return
	}

	rw.Header().Set("Content-Type", "application/dns-message")
	rw.Header().Set("Content-Length", fmt.Sprintf("%d", len(response)))
	rw.WriteHeader(200)
	rw.Write(response)
}
