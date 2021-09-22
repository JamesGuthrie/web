+++
title = "HTTPS DNS record"
[taxonomies]
tags = ["TIL", "DNS"]
+++

TIL there is a proposal for a new `HTTPS` DNS record type which can be used to increase the security and speed of https requests to a website. Cloudflare has a good [writeup](https://blog.cloudflare.com/speeding-up-https-and-http-3-negotiation-with-dns/) on the subject. It's not completely standardized yet, the IETF is [working on it](https://datatracker.ietf.org/doc/draft-ietf-dnsop-svcb-https/).

The basic idea is to embed information about HTTPS capabilities of a website in DNS. When the browser makes a request for `HTTPS cloudflare.com`, the HTTPS entry will then inform the browser whether HTTPS is supported and which connection types (HTTP2, HTTP3, etc.). Additionally, the HTTPS record can pass an IP hint. With this information, the browser can immediately open a connection using the most optimal protocol.

The usual DNS spelunking tool `dig` _does_ support querying HTTPS records, but only in the most recently released version (9.16.21). The easiest way to get and test this is with Docker:

```
> docker run -ti internetsystemsconsortium/bind9:9.16 bash
# apt install -y bind9-dnsutils
# dig -v
DiG 9.16.21-Ubuntu
# dig HTTPS cloudflare.com

; <<>> DiG 9.16.21-Ubuntu <<>> HTTPS cloudflare.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 16925
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;cloudflare.com.			IN	HTTPS

;; ANSWER SECTION:
cloudflare.com.		377	IN	HTTPS	1 . alpn="h3,h3-29,h3-28,h3-27,h2" ipv4hint=104.16.132.229,104.16.133.229 ipv6hint=2606:4700::6810:84e5,2606:4700::6810:85e5

;; Query time: 2 msec
;; SERVER: 192.168.65.5#53(192.168.65.5)
;; WHEN: Wed Sep 22 09:33:23 UTC 2021
;; MSG SIZE  rcvd: 123
```

The effective content of the HTTPS record for cloudflare.com is `1 . alpn="h3,h3-29,h3-28,h3-27,h2" ipv4hint=104.16.132.229,104.16.133.229 ipv6hint=2606:4700::6810:84e5,2606:4700::6810:85e5`.
