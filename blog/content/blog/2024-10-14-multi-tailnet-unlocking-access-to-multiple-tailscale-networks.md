+++
title = "Multi-Tailnet: Unlocking Access to Multiple Tailscale Networks"
[taxonomies]
tags = [ "tailscale", "tailnet", "networking", "Linux", "namespace" ]
+++

A while ago, I decided to move my development environment to a Linux machine. I'm a diehard macOS user, though, and I didn't want to give up on the shiny GUI. I chose to set up a server machine that I SSH into from my MacBook Pro. For my IDE, I run IntelliJ in "remote development" mode with the Linux machine as the backend. I've now gotten to the point where I'm pretty comfortable with the setup.

One issue I had early on was keeping persistent SSH sessions that would recover from network instability, etc. The first step to solving this was using Tailscale to connect my laptop to other devices in my network. This gives all devices a fixed address (and name) that they can be reached on, allowing me to continue an SSH session even if I leave the house with my laptop and connect via mobile internet. The second step was to use [Eternal Terminal][et], which is amazing -- I will never go back. Eternal Terminal uses a custom protocol to persist sessions, even if the underlying connection is broken.

[et]: https://eternalterminal.dev/

On a normal day I spend 90% of my time in an et window on the remote machine. This is great.

At work we _also_ use Tailscale to provide authenticated access to specific machines. This is not great.

## The problem with Tailscale

Unfortunately, Tailscale doesn't allow simultaneous connections to multiple networks (which they call "tailnets"). This means that when I do `$work_stuff`, I have to switch from my private tailnet to the work tailnet, which disrupts connection to my Linux machine and freezes `et` sessions (which resume immediately when I switch back). This means I have to use my Mac to switch between tailnets. While switching is very fast, it's not ideal.

A couple of days ago I got fed up enough about this situation that I started looking into how to do it. I found a lot of "you can't do this" or "it only works in this way", but I didn't find anybody talking about the solution that I came up with. So, I figured that's a great reason to write this post.

## Solutions that don't work

If you search for "Tailscale multiple network", you get solutions that fall into a few different categories:
1. Switch tailnets ([1][switch-tailnets-1])
2. [Share] the devices on with other users ([1][shared-devices-1])
3. Run a second tailscaled in [userspace-networking] mode and use a SOCKS5 proxy ([1][socks-proxy-1], [2][socks-proxy-2], [3][socks-proxy-3])
4. Run two tailscaled instances, and hope it works ([1][2tsd-pray], [2][2tsd-pray-2])

Also [this](https://forum.tailscale.com/t/connect-two-different-network/4014/2) hopeful answer on the Tailscale forum suggests that it "just works" (narrator: it does not).

[Share]: https://tailscale.com/kb/1084/sharing
[userspace-networking]: https://tailscale.com/kb/1112/userspace-networking

[switch-tailnets-1]: https://forum.tailscale.com/t/support-multiple-networks-from-one-device/159
[shared-devices-1]: https://www.reddit.com/r/Tailscale/comments/sxu0jk/comment/hxu35qs/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
[socks-proxy-1]: https://github.com/tailscale/tailscale/issues/183#issuecomment-1912404153
[socks-proxy-2]: https://gist.github.com/drio/b90b772a2857e873bf95214841ee95d1
[socks-proxy-3]: https://gist.github.com/dsnet/b0a602b15651e9502b9d8c5601053bb9
[2tsd-pray]: https://github.com/tailscale/tailscale/issues/183#issuecomment-598464240
[2tsd-pray-2]: https://github.com/tailscale/tailscale/issues/183#issuecomment-2065814416

Let's quickly go through these options:
1. Already covered this: it's a (minor) hassle to switch tailnets, and forces me back to my Mac.
2. I'm not an admin on the work tailnet, and I doubt that work wants to share machines with my tailnet. Also, just no.
3. This could work, but it requires the software or system to be proxy-aware, which could work for  some cases, but I would really like it to work in all cases and without additional configuration.
4. Aside from the warning notes around why this doesn't work, it seems like maybe this is what I want, _if_ it could work.

## Experimenting with Tailscale

I spent some time trying to understand what the Tailscale daemon does. I ran it in userspace-networking mode, and I tried running a  second daemon, using a different tunnel interface name. This does work, but it's fragile: the two Tailscale daemons battle over routes, iptables rules, and who gets to be the DNS server. If they're started in the wrong order then I'm able to access resources on the work tailnet, but the private tailnet becomes disconnected.

At this point I wondered: can I just put the second Tailscale daemon in a separate network namespace?

Network namespaces isolate the networking stack between processes. A network namespace has its own interfaces, routes, etc. By putting the second Tailscale daemon in its own namespace, I know that it won't mess with anything that the other Tailscale daemon is doing. The challenge is that in order for this to be useful, we need to be able to know how to route traffic to and from the network namespace.

In my case I can make some simplifications because:
- The resources I want to access are in a predefined (static) subnet which the work tailnet routes.
- I don't care about any of the other machines in the work tailnet.
- The DNS names for the machines I'm interested in connecting to resolve publicly (to a private address), so I don't need Tailscale's DNS.

## Actually doing the thing

Okay, enough waffling, let's do it. (Note: all of the following commands require `sudo` on my machine, which I've elided for brevity).

Start by creating a new network namespace called `tailns`:

```bash
ip netns add tailns
```

Bring up the loopback interface in the network namespace:
```bash
ip -n tailns link set dev lo up
```

Bring up a new veth pair with `veth0` on the host, and `veth1` in the network namespace, giving them the addresses `192.168.101.1/24` and `192.168.101.2/24`, respectively.
```bash
ip link add veth0 type veth peer name veth1
ip link set veth1 netns tailns

ip addr add 192.168.101.1/24 dev veth0
ip link set dev veth0 up

ip -n tailns addr add 192.168.101.2/24 dev veth1
ip -n tailns link set dev veth1 up
```

Enable IP forwarding, set up a default route in the network namespace, and route traffic destined for the work subnet to the network namespace:
```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
ip -n tailns route add default via 192.168.101.1
ip route add <WORK_SUBNET> via 192.168.101.2
```

Enable forwarding between the primary interface (`enp0s31f6`) and `veth0`:
```bash
iptables -A FORWARD -i enp0s31f6 -o veth0 -j ACCEPT
iptables -A FORWARD -o enp0s31f6 -i veth0 -j ACCEPT
```

NAT outbound traffic from within the network namespace (i.e., Tailscale's "public" traffic), and NAT traffic from the host network destined for the work tailnet:
```bash
iptables -t nat -A POSTROUTING -s 192.168.101.0/255.255.255.0 -o enp0s31f6 -j MASQUERADE
ip netns exec tailns iptables -t nat -A POSTROUTING -s 192.168.101.0/255.255.255.0 -o tailscale0 -j MASQUERADE
```

Run the Tailscale daemon inside the network namespace:
```bash
ip netns exec tailns tailscaled -tun tailscale0 --socket /tmp/tstail/tstail.socket --statedir=/tmp/tstail --state /tmp/tstail/tstail.state
```
Note: the `--socket` parameter tells tailscaled where to listen for connections from the `tailscale` client. The `--statedir` and `--state` parameters determine where tailscaled will store its state (which it populates when logging onto the tailnet). It's crucial that these are configured correctly, otherwise the second Tailscale daemon will clobber the state of the first, breaking everything.

Log in to the work tailnet (using the `--socket` parameter specified to the daemon), and accept routes for the available subnets:
```bash
tailscale --socket /tmp/tstail/tstail.socket login --accept-routes
```

And it works!

## Limitations

One shortcoming of this setup is that DNS is broken in the network namespace. I don't really care about that because nothing within the network namespace needs DNS. I think it could be (partially) resolved by setting up an `/etc/resolv.conf` for the network namespace pointing to a resolver. I suspect that the tailscale daemon in the network namespace is getting confused because it sees the `100.100.100.100` resolver in `/etc/resolv.conf`.

Another shortcoming is that the subnets to be routed are configured manually. It would probably be possible to use a routing daemon to share routes between the host network and the network namespace, but I don't need that. 

Obviously this is more of a proof-of-concept than something ready to handle daily traffic. For that it would make sense to set all of this up as systemd services, which I have done on my computer. Maybe I'll blog about it sometime, but this post it getting too long.

## Summary

In this blog post I talked about the difficulties in connecting to two Tailscale tailnets simultaneously. I explored various approaches and found that running Tailscale in a network namespace is both feasible and effective. I provided concrete steps to setting up a network namespace to run Tailscale in, with virtual interfaces, firewalling, and routing. While I was only interested in providing access to subnets which are shared via the work tailnet, I suspect that with further tweaking this approach could provide "proper" access to all devices on two tailnets.
