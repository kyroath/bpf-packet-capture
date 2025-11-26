const std = @import("std");
const ubytes = @import("../utils/bytes.zig");

pub const Proto = enum(u8) {
    ICMP = 0x0001,
    TCP = 0x0006,
    UDP = 0x0011,
    UNKNOWN = 0x0000,
};

fn proto_from_int(value: u16) Proto {
    return std.meta.intToEnum(Proto, value) catch Proto.UNKNOWN;
}

pub const IPV4 = struct {
    version: u4,
    ihl: u4,
    length: u16,
    identification: u16,
    flags: u3,
    fragment_offset: u15,
    ttl: u8,
    proto: Proto,
    checksum: u16,
    src_addr: []const u8,
    dst_addr: []const u8,
    payload: []const u8,

    pub fn init(buf: []const u8) IPV4 {
        const version: u4 = @truncate(buf[0] >> 4);
        const ihl: u4 = @truncate(buf[0]);

        const length = ubytes.pack_u8_to_u16_big(buf[2..]);
        const identification = ubytes.pack_u8_to_u16_big(buf[4..]);
        const flags: u3 = @truncate(buf[6] >> 5);
        const fragment_offset = (@as(u15, buf[6]) << 3) | @as(u15, buf[7]);

        const ttl = buf[8];
        const proto = buf[9];
        const checksum = ubytes.pack_u8_to_u16_big(buf[10..]);

        const src_addr = buf[12..16];
        const dst_addr = buf[16..20];

        const payload = buf[20..];

        return IPV4{
            .version = version,
            .ihl = ihl,
            .length = length,
            .identification = identification,
            .flags = flags,
            .fragment_offset = fragment_offset,
            .ttl = ttl,
            .proto = proto_from_int(proto),
            .checksum = checksum,
            .src_addr = src_addr,
            .dst_addr = dst_addr,
            .payload = payload,
        };
    }
};
