+++
title = "Deploying NixOS on a Raspberry Pi from a Mac (Part 1)"
[taxonomies]
tags = [ "Nix", "NixOS", "Raspberry Pi", "macOS" ]
+++

In my last [blog post][PrevBlogPost], I documented setting up NixOS on a Raspberry Pi. That Pi has gone on to get a number of services installed on it, and I'm having fun with it. I've also acquired another Pi which I'm using as my internet router. That's really a story for another time, but suffice to say the [Compute Module][ComputeModule] with the IoT router [carrier][IoTRouter] board is pretty cool.

The point is that I now have two Pis running NixOS, and two Mac laptops (one M1 and one Intel) setup with [nix-darwin][NixDarwin], so also a NixOS of sorts. Since embarking on the NixOS journey (and boy does it _feel_ like a journey), I've had this great idea that I should somehow put all of my NixOS configs into version control. Mostly because I forget stuff, and more likely than not I'm going to break something and have no idea how to get it back again.

Every time I attempt to get started on this I end up getting stuck on _something_ which I break my head over, and stops me from making progress. Two major points which I haven't figured out are are:
1. How to manage the configurations
2. How to deal with secrets

For the first part, the simplest thing would be to just toss each host's config into its own repo, and be done with it. But somehow that doesn't feel right. I won't really get any re-use between the different machines, which would be nice. A few years ago, it seemed as though NixOps was the answer to this problem, but that seems to have been in a "oh, 2.0 is just around the corner" limbo for... years? And it seems as though in the meantime other alternatives have cropped up.

For the second part, while there is a [wiki][SecretsWiki] article, every time I read it I realise I'm going to have to invest hours just to figure out which of the alternatives is the ~~best~~ least broken (let's be honest).

Today I decided that I was going to ignore secrets for now, and figure out the config management and deployment. This started by swearing off NixOps (it's written in Python anyway 🤢), to find _some_ other solution. I briefly looked at [deploy-rs][DeployRs], but there were some bits that I didn't grok, and I just wanted something that looked like it would work.

Fortunately, there is the shining light illuminated by [Christine][Christine], who consistently puts out _excellent_ guides on how to get stuff done with NixOS. Today's story is about falling down a rabbit hole of ~~fun~~ pain, inspired by her [article][XeMorphArticle] on using [morph][Morph] to manage hosts. It looks simple enough: a sprinkling of config, run `morph build`, and it should just work. Yay!

The basic idea is that I would set up one repository containing the configs for all of the devices on my network, then if I need to reconfigure them I can run morph from my laptop, which will build the system and push it onto the target machine, awesome! The fact that the laptop is more powerful than the Pi is great, now I don't have to ensure that I have enough swap space, and overwhelm the poor Pi with evaluating the Nix config, (or compiling Rust 😱) while it's trying to do other work.

So I got to work. I dilligently set up my user config, my hosts, my `network.nix`, and ran `morph build`. Only to be confronted by this

```bash
error: assertion '(stdenv).isLinux' failed

       at /nix/store/zsk4yvfx2v2a1r682djn1sgsim2akf6f-nixpkgs-22.05/nixpkgs/pkgs/os-specific/linux/kernel/generic.nix:70:1:

           69|
           70| assert stdenv.isLinux;
             | ^
           71|
``` 

That's not what I expected. We're wanting to deploy _to_ Linux from Darwin, and NixOS doesn't want to build the kernel on MacOS. Kinda makes sense, but don't people do this? Shouldn't this just work?

A search retrieved the `nixpkgs.localSystem.system` configuration parameter, which I can add to my host configuration in `network.nix`, setting it to:

```
  nixpkgs.localSystem.system = "aarch64-linux";
```

Now the build fails with:

```
error: a 'aarch64-linux' with features {} is required to build '/nix/store/ds3174h0ycsd54013k86j8xh896gmhi2-healthcheck-commands.txt.drv', but I am a 'aarch64-darwin' with features {benchmark, big-parallel, nixos-test}
```

More searching the internet turns up the `nixpkgs.crossSystem.system` parameter, which can also be configured to force cross-compilation. Fiddling around with this didn't seem to improve the situation much... Maybe I need to explore this more, but it seems as though cross compilation is more of a "here be dragons" thing, so 🤷.

Getting back to the "I am a ...", Nix _can_ be configured to use a [remote builder][RemoteBuilder] on a different system (e.g. `aarch64-linux`) to build for the desired target. Yay!

Somehow in my frantic internet searching I'd already come across [nix-docker][NixDocker], which seems to cover the bases: start a docker image for the target system, configure ssh access to it, tell Nix about it, profit!

## Setting up a docker-based remote Nix builder

Fan-tastic. So I want an aarch64 docker image with nix inside that I can ssh into. For some unknown reason, the [lnl7/nix][LnL7NixDocker] pre-built ssh images aren't provided for aarch64. No big deal, we can just use the base [nixos/nix:latest-arm64][NixOsNixDocker] image, and add our ssh config into that! Not so fast. The `nixos/nix` image is some kinda weird bastard thing and doesn't want to let itself be configured. The root user is locked, and `/etc/` seems to be readonly, so it's not possible to unlock the user (or at least I didn't figure out how).

No big deal, the `nix-docker` repo has tools in there to build the docker image. Let's just use an ubuntu aarch64 image, install nix in that, and then nix-build the nix-docker base docker image for a different architecture. Fortunately at least one brave soul has successfully walked this path and lived to tell the [tale][BraveSoul]. Surely nothing will go wrong this time! (He says, beginning to sob).

It didn't work at first. The pain and anguish that I experienced motivated me to write this blog post.

A few hundred words, and a couple of tweaks later, I did get it to build. The following patch to `nix-docker` shows the changes I made:

```patch
diff --git a/default.nix b/default.nix
index c256af5..a85d8b1 100644
--- a/default.nix
+++ b/default.nix
@@ -6,7 +6,7 @@ let

   inherit (native.lib) concatStringsSep genList;

-  pkgs = import unstable { system = "x86_64-linux"; };
+  pkgs = import unstable { system = "aarch64-linux"; };

   native = import nixpkgs { inherit system; };
   unstable = native.callPackage src { stdenv = native.stdenvNoCC; };
@@ -167,5 +167,5 @@ in

 {
   inherit baseDocker latestDocker sshDocker;
-  inherit env run image contents path unstable;
+  inherit run image contents path unstable;
 }
```

One is obvious: we want to build for aarch64, not x86_64. The other is not so obvious. Apparently the `env` derivation is a bit out of date, and looks to be doing things that are quite un-nixy. Not a problem, we can just remove it and run `nix-build` in our docker container. This produces a number of results, but the one we care about looks kind of like: `/nix/store/3w6f8d07lv8f6gfsrdkvm0qvaflijvls-docker-image-nix-base.tar.gz`.

If I were using docker-in-docker, then I might attempt to build all of the docker images in the ubuntu container, but I'm already what feels like 15 yaks deep. Instead we'll `docker cp` that file from the ubuntu container to the host system. With a quick `docker load < <path to file>` we have our `nix-base:2020-09-11` image _for aarch64_! Finally, a small win! We can repeat the same `docker cp` procedure for the other two Dockerfiles which were produced. One is for the `lnl7/nix` image, and the other is for the `lnl7/ssh` image. A couple of `docker build`s later, and we've got an aarch64 `lnl7/ssh` docker image!

Following the instructions from `nix-docker`, we now run `docker run --restart always --name nix-docker -d -p 3022:22 lnl7/nix:ssh`. Next, setup an ssh host file entry in your `darwin-configuration.nix` (I'm assuming that you're using nix-darwin here).

```nix
  programs.ssh = {
    builder = {
      hostname = "127.0.0.1";
      user = "root";
      port = 3022;
      identityFile = "/path/to/nix-docker/ssh/insecure_rsa";
    };
```

Do the same for the root user by adding the following to `/etc/ssh/ssh_config`:

```
Host builder
  Port 3022
  User root
  HostName 127.0.0.1
  IdentityFile /Users/james/Development/nix-docker/ssh/insecure_rsa
```

At this point you should try both `ssh builder` and `root ssh builder` to a) validate that this works, and b) set the ssh host key. I kind of skipped over why root needs to be able to connect with ssh. Apparently the Nix builders are running as root, and not my user, so without that config, this whole thing doesn't work.

Now setup a buildmachine entry in your `darwin-configuration.nix`:

```
  nix = {
    package = pkgs.nix;
    distributedBuilds = true;
    buildMachines = [{
      hostName = "builder";
      system = "aarch64-linux";
      maxJobs = 10;
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
    }];
  };
```

Finally, validate that local nix can speak to the builder:

```
> sudo nix store ping --store ssh://builder
Store URL: ssh://builder
```

It works 🎉

# Morph build-ing

Now let's validate that `morph build` uses our builder.

```
> morph build network.nix
Selected 1/1 hosts (name filter:-0, limits:-0):
	  0: router (secrets: 0, health checks: 0, tags: )

...

/nix/store/kv6gr5jg3hdfcyp14g8z3j1dia98gb7c-morph
nix result path:
/nix/store/kv6gr5jg3hdfcyp14g8z3j1dia98gb7c-morph
```

🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉

Wow! Well that's enough success for one evening. In part II we'll take a look at deploying the config to the Pis, and maybe I'll figure out the secrets thing.

# Addendum (19.12.2022)

I noticed that this blog post is missing some of the exact details, so I wrote [another post][NextBlogPost] which fills in some gaps.


[PrevBlogPost]: /blog/nixos-on-raspberry-pi/
[ComputeModule]: https://www.raspberrypi.com/products/compute-module-4/?variant=raspberry-pi-cm4001000
[IoTRouter]: https://wiki.dfrobot.com/Compute_Module_4_IoT_Router_Board_Mini_SKU_DFR0767
[NixDarwin]: https://github.com/LnL7/nix-darwin
[SecretsWiki]: https://nixos.wiki/wiki/Comparison_of_secret_managing_schemes
[Christine]: https://xeiaso.net/
[XeMorphArticle]: https://xeiaso.net/blog/morph-setup-2021-04-25
[Morph]: https://github.com/DBCDK/morph
[DeployRs]: https://github.com/serokell/deploy-rs
[RemoteBuilder]: https://nixos.org/manual/nix/stable/advanced-topics/distributed-builds.html
[NixDocker]: https://github.com/LnL7/nix-docker
[LnL7NixDocker]: https://hub.docker.com/r/lnl7/nix
[NixOsNixDocker]: https://hub.docker.com/r/nixos/nix
[BraveSoul]: https://github.com/NixOS/nix/issues/4219#issuecomment-917673219
[NextBlogPost]: /blog/docker-based-nix-builder-macos
