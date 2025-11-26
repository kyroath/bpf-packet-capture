const std = @import("std");
const ubytes = @import("../utils/bytes.zig");

pub const ICMP = struct {
    icmp_type: ICMP_Type,
    code: u8,
    checksum: u16,
    identifier: u16,
    sequence_number: u16,
    timestamp: struct {
        sec: u32,
        usec: u32,
        joined: u64,
    },

    pub const ICMP_Type = enum(u8) {
        ECHO_REPLY = 0x00,
        ECHO_REQUEST = 0x08,
        UNKNOWN = 0xFF,
    };

    fn icmp_type_from_int(value: u16) ICMP_Type {
        return std.meta.intToEnum(ICMP_Type, value) catch ICMP_Type.UNKNOWN;
    }

    pub fn init(buf: []const u8) ICMP {
        const icmp_type = buf[0];
        const code = buf[1];
        const checksum = ubytes.pack_u8_to_u16_big(buf[2..]);
        const identifier = ubytes.pack_u8_to_u16_big(buf[4..]);
        const sequence_number = ubytes.pack_u8_to_u16_big(buf[6..]);
        const sec = ubytes.pack_u8_to_u32(buf[8..]);
        const usec = ubytes.pack_u8_to_u32(buf[12..]);
        const joined: u64 = @as(u64, sec) * 1000000 + usec;

        return ICMP{
            .icmp_type = icmp_type_from_int(icmp_type),
            .code = code,
            .checksum = checksum,
            .identifier = identifier,
            .sequence_number = sequence_number,
            .timestamp = .{
                .sec = sec,
                .usec = usec,
                .joined = joined,
            },
        };
    }
};
