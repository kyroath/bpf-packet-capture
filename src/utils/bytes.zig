pub fn pack_u8_to_u16(buffer: []const u8) u16 {
    return @as(u16, buffer[0]) |
        (@as(u16, buffer[1]) << 8);
}

// big endian version
pub fn pack_u8_to_u16_big(buffer: []const u8) u16 {
    return (@as(u16, buffer[0]) << 8) |
        @as(u16, buffer[1]);
}

pub fn pack_u8_to_u32(buffer: []const u8) u32 {
    return @as(u32, buffer[0]) |
        (@as(u32, buffer[1]) << 8) |
        (@as(u32, buffer[2]) << 16) |
        (@as(u32, buffer[3]) << 24);
}

pub fn pack_u32_to_u64(buffer: []const u32) u64 {
    return @as(u64, buffer[0]) |
        (@as(u64, buffer[1]) << 32);
}
