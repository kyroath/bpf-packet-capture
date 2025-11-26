const std = @import("std");
const ubytes = @import("../utils/bytes.zig");
const udebug = @import("../utils/debug.zig");

pub const EtherType = enum(u16) {
    IPV4 = 0x0800,
    ARP = 0x0806,
    IPv6 = 0x86DD,
    UNKNOWN = 0x0000,
};

fn ether_type_from_int(value: u16) EtherType {
    return std.meta.intToEnum(EtherType, value) catch EtherType.UNKNOWN;
}

pub const Ethernet = struct {
    dst_mac: []const u8,
    src_mac: []const u8,
    ether_type: EtherType,
    payload: []const u8,

    pub fn init(buffer: []const u8) Ethernet {
        const dest_mac = buffer[0..6];
        const src_mac = buffer[6..12];
        const ether_type = ubytes.pack_u8_to_u16_big(buffer[12..]);
        const payload = buffer[14..];

        return Ethernet{
            .dst_mac = dest_mac,
            .src_mac = src_mac,
            .ether_type = ether_type_from_int(ether_type),
            .payload = payload,
        };
    }
};
