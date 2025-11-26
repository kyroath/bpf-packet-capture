const std = @import("std");
const posix = std.posix;
const c = std.c;

extern "c" fn ioctl(fd: c_int, request: c_ulong, ...) c_int;

const BIOCSETIF = 0x8020426c;
const BIOCGBLEN = 0x40044266;
const BIOCIMMEDIATE = 0x80044270;

const ifreq = extern struct {
    name: [16]u8,
    _padding: [16]u8,
};

fn open_bpf() !posix.fd_t {
    var i: u8 = 0;
    while (i < 99) : (i += 1) {
        var path_buf: [16]u8 = undefined;
        const path = try std.fmt.bufPrint(&path_buf, "/dev/bpf{d}", .{i});
        const fd = posix.open(path, .{ .ACCMODE = .RDWR }, 0);
        return fd;
    }
    return error.NoBPFDevice;
}

fn bind_interface(fd: posix.fd_t, name: []const u8) !void {
    var ifr: ifreq = std.mem.zeroes(ifreq);
    @memcpy(ifr.name[0..name.len], name);

    if (ioctl(fd, BIOCSETIF, &ifr) != 0) {
        return error.BindFailed;
    }
}

fn set_immediate(fd: posix.fd_t) !void {
    var immediate: u32 = 1;
    if (ioctl(fd, BIOCIMMEDIATE, &immediate) != 0) {
        return error.SetImmediateFailed;
    }
}

fn get_buffer_length(fd: posix.fd_t) !u32 {
    var len: u32 = 0;
    if (ioctl(fd, BIOCGBLEN, &len) != 0) {
        return error.GetBufferLengthFailed;
    }
    return len;
}

pub const Filter = struct {
    fd: posix.fd_t,
    buf_len: u32,
    buffer: []u8,

    pub fn init(interface_name: []const u8, allocator: std.mem.Allocator) !Filter {
        const fd = try open_bpf();
        try bind_interface(fd, interface_name);
        try set_immediate(fd);

        const buf_len = try get_buffer_length(fd);
        const buffer = try allocator.alloc(u8, buf_len);

        return Filter{
            .fd = fd,
            .buf_len = buf_len,
            .buffer = buffer,
        };
    }

    pub fn deinit(self: Filter, allocator: std.mem.Allocator) void {
        posix.close(self.fd);
        allocator.free(self.buffer);
    }

    pub fn read(self: Filter) ![]const u8 {
        const bytes_read = try posix.read(self.fd, self.buffer);
        return self.buffer[0..bytes_read];
    }
};
