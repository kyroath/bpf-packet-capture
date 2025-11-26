# BPF Packet Parser

> Disclaimer: This is not a comprehensive or a performant implementation. Consider it as a starting point / reference if needed.

This repository is a simple packet capture program / packet parser. The parsers and packet structures can be found under `src/packet/<type>.zig`, where each file corresponds to one type of packet, regardless of the layer. Currently the following packets are supported:
- BPF packets with headers ([reference](https://github.com/freebsd/freebsd-src/blob/73dd00f2fd7de2a5d8dda8fa25ebcd7c8964ff52/sys/net/bpf.h#L200-L206))
- Ethernet Frames ([802.3 on Layer 2, no preamble/SDF](https://en.wikipedia.org/wiki/Ethernet_frame#Structure))
- IPv4 datagrams ([RFC 791](https://datatracker.ietf.org/doc/html/rfc791#section-3.1))
- ICMP ping packets ([RFC 792](https://datatracker.ietf.org/doc/html/rfc792))

## Running

As it stands, the executable part is currently only set up to be run on MacOS and not tested on other platforms. To run, install Zig v15.+ and run the application via `sudo zig build run`. The BPF setup requires root.

## Interesting files
- `setup.zig` contains the setup for the BPF for a given network interface
- `packet/bpf.zig` contains the structure of the BPF headers, which is not very commonly seen.

----

A great tool to use to parse unsupported packets is [packetor](https://packetor.com).
