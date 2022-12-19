+++
title = "Docker-based Nix builders on macOS"
[taxonomies]
tags = [ "NixOS", "Nix", "Docker", "macOS" ]
+++

This is a quick one, more of an addendum to my last [blog post][LastBlogPost]. In that, I ~~shared info on~~ mostly ranted about deploying to NixOS on a Raspberry Pi from macOS. The main thing that I achieved in that post was configuring a docker-based nix builder for NixOS.

Taking a look at that post again, I realised that it mostly had some pointers to the broad strokes of how to get things working, but without providing exact (or reproducible) instructions. I also realised that one of the statements I made in that post was incorrect, namely the following:

> The nixos/nix image is some kinda weird bastard thing and doesn't want to let itself be configured. The root user is locked, and /etc/ seems to be readonly, so it's not possible to unlock the user (or at least I didn't figure out how).

It turns out that it is possible to use the `nixos/nix` image as the base image for a docker-based nix builder. I'm not sure why I wasn't able to get it to work before.

I put together the Dockerfile and a Makefile with some instructions in a [repo]. The README contains the instructions that you'll need to follow.

You may wonder: "why provide a Dockerfile and not a docker image which can be reused?". I initially wanted to do this, but the main issue is that of ssh keys. If I did provide a Docker image, you would have to volume-mount two paths into the container to set up the certificates. Could be done, but this way seems simpler for a local-only setup, which this is likely to remain.

Also, as I note in the README, this approach is slightly sloppy around architectures. If you want to have builders for both aarch64 and x86_64, you may need to make some changes. I may be bitten by this in the future and update this blog post.

[LastBlogPost]: /blog/deploy-nixos-raspi/
[repo]: http://github.com/JamesGuthrie/nix-docker-builder-macos

