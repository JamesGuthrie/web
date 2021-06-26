+++
title = "Hello World!"
[taxonomies]
tags = [ "rust", "DNS" ]
+++

Welcome to my blog! Setting up this blog has been a project in itself. I would like to explain some pieces over the next few blog articles. This article should give a sense of what, and why.

When I decided that I wanted to have a website again, I realised that I could either do things the simple way (by using a hosted Wordpress or similar), or the hard way (no hosted services). I wanted to make this into a learning experience, so I chose the hard way. I was thoroughly inspired by the [fly](https://fly.io) platform and its magical global anycast routing. That formed the basis of where and how I would like to deploy the website - and is a notable exception to the "no hosted services" rule. Another source of excitement for me at the moment is the Rust programming language. So I've taken on the challenge of solving as many things with tooling in the Rust ecosystem as possible (although this is not 100% successful so far).

At the moment, I have two main "services" running on fly: a DNS server which hosts zone files for a few domains that I own, and this website.

Setting up my own DNS server was a fun adventure, which I documented in the form of a [guide](https://github.com/fly-apps/coredns) which has formed part of the public fly documentation. I initially started it with the intention of using [trust-dns](https://github.com/bluejekyll/trust-dns), but hit some trouble along the way. The people at fly were looking for a guide using [Coredns](https://coredns.io/), so I thought I would take a look at using that instead. I found Coredns' configuration to be a little more straightforward than trust-dns', so I decided to stick with Coredns. I may switch back to trust-dns at some point just for the purism.

This website is generated with [zola](https://www.getzola.org/), a static site generator written in Rust! Zola spits out a few static html files which need to be served by a http server. Naturally arises the question of how to serve the html files. When looking into Rust web servers, I figured that this was something which I could feasibly put together myself (naturally on top of some excellent libraries in the Rust ecosystem). And so [httpserve](https://github.com/JamesGuthrie/httpserve), an HTTP file server built on top of [hyper](https://hyper.rs/) was born. This website is being served to you from a webserver which I wrote - how cool!

Anyway, that's about all that I have to report for now. There are still some things which I haven't figured out yet: analytics and email are two topics which I'm thinking of, and wondering if it's worth the pain of trying to host those myself.
