const std = @import("std");

const udebug = @import("utils/debug.zig");
const Filter = @import("setup.zig").Filter;
const BPF = @import("packet/bpf.zig").BPF;

const Ethernet = @import("packet/ethernet.zig").Ethernet;
const IPV4 = @import("packet/ipv4.zig").IPV4;
const ICMP = @import("packet/icmp.zig").ICMP;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // change the interface from `en0` to something appropriate.
    var filter = try Filter.init("en0", allocator);
    defer filter.deinit(allocator);

    std.debug.print("BPF ready on fd={d}, buffer={d} bytes\n", .{ filter.fd, filter.buf_len });

    // read 5 packets and quit, for testing.
    var i: i32 = 1;
    while (i <= 5) : (i += 1) {
        const buffer = try filter.read();
        std.debug.print("\nPacket {d} ({d} bytes):\n", .{ i, buffer.len });

        const bpf = BPF.init(buffer);
        try udebug.print_timestamp(bpf.timestamp.joined);
        std.debug.print(
            "capture {d} bytes, actual {d} bytes, header {d} bytes\n",
            .{ bpf.capture_len, bpf.actual_len, bpf.header_len },
        );

        const eth = Ethernet.init(bpf.packet);
        std.debug.print("\nEthernet Frame type {s} ({d} bytes)\n", .{
            @tagName(eth.ether_type),
            eth.payload.len,
        });
        udebug.print_hex(eth.src_mac, 0, ":", false);
        std.debug.print(" -> ", .{});
        udebug.print_hex(eth.dst_mac, 0, ":", true);
        std.debug.print("\n", .{});

        const ip = IPV4.init(eth.payload);
        std.debug.print("Version {x:0>2}, IHL {x:0>2}\n", .{ ip.version, ip.ihl });
        std.debug.print("Length {d} bytes, TTL {d}\n", .{ ip.length, ip.ttl });
        std.debug.print("Protocol {s}\n", .{@tagName(ip.proto)});
        udebug.print_decimal(ip.src_addr, 0, ".", false);
        std.debug.print(" -> ", .{});
        udebug.print_decimal(ip.dst_addr, 0, ".", true);
        std.debug.print("\n", .{});

        const icmp = ICMP.init(ip.payload);
        std.debug.print("Type {s}, code {d}\n", .{ @tagName(icmp.icmp_type), icmp.code });
        std.debug.print("Checksum {d}, identifier {d}\n", .{ icmp.checksum, icmp.identifier });
        std.debug.print("Sequence {d}\n", .{icmp.sequence_number});
        try udebug.print_timestamp(icmp.timestamp.joined);
        std.debug.print("\n", .{});

        udebug.print_hex_dump(bpf.packet);
        std.debug.print("\n------------------\n", .{});
    }
}
