const std = @import("std");
const posix = std.posix;
const c = std.c;

const udebug = @import("utils/debug.zig");
const BPF = @import("bpf.zig").BPF;
const Filter = @import("setup.zig").Filter;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var filter = try Filter.init("en0", allocator);
    defer filter.deinit(allocator);

    const fd = filter.fd;
    const buf_len = filter.buf_len;
    const buffer = filter.buffer;

    std.debug.print("BPF ready on fd={d}, buffed={d} bytes\n", .{ fd, buf_len });

    var i: i32 = 1;
    while (i <= 5) : (i += 1) {
        const bytes_read = try posix.read(fd, buffer);
        const bf_actual = buffer[0..bytes_read];
        std.debug.print("\nPacket {d} ({d} bytes):\n", .{ i, bytes_read });

        const bpf = BPF.init(bf_actual);
        try udebug.printTimestamp(bpf.timestamp.joined);
        std.debug.print(
            "capture {d} bytes, actual {d} bytes, header {d} bytes\n",
            .{ bpf.capture_len, bpf.actual_len, bpf.header_len },
        );

        udebug.print_hex_dump(bf_actual);
    }
}
