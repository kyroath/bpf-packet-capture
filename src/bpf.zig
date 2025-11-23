const ubytes = @import("utils/bytes.zig");

pub const BPF = struct {
    timestamp: struct {
        sec: u32,
        usec: u32,
        joined: u64,
    },
    capture_len: u32,
    actual_len: u32,
    header_len: u16,

    pub fn init(buffer: []const u8) BPF {
        const sec = ubytes.pack_u8_to_u32(buffer[0..]);
        const usec = ubytes.pack_u8_to_u32(buffer[4..]);
        const joined: u64 = @as(u64, sec) * 1000000 + usec;

        const capture_len = ubytes.pack_u8_to_u32(buffer[8..]);
        const actual_len = ubytes.pack_u8_to_u32(buffer[12..]);
        const header_len = ubytes.pack_u8_to_u16(buffer[16..]);

        return BPF{
            .timestamp = .{
                .sec = sec,
                .usec = usec,
                .joined = joined,
            },
            .capture_len = capture_len,
            .actual_len = actual_len,
            .header_len = header_len,
        };
    }
};
