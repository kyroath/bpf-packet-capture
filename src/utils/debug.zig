const std = @import("std");

pub fn print_hex_dump(buffer: []const u8) void {
    print_hex(buffer, 16, " ", true);
}

pub fn print_hex(buffer: []const u8, line_len: usize, separator: []const u8, newline: bool) void {
    for (buffer[0..buffer.len], 0..) |byte, idx| {
        std.debug.print("{x:0>2}", .{byte});
        if (line_len != 0 and (idx + 1) % line_len == 0) {
            std.debug.print("\n", .{});
        } else if (idx + 1 != buffer.len) {
            std.debug.print("{s}", .{separator});
        }
    }
    if (newline) {
        std.debug.print("\n", .{});
    }
}

pub fn print_decimal(buffer: []const u8, line_len: usize, separator: []const u8, newline: bool) void {
    for (buffer[0..buffer.len], 0..) |byte, idx| {
        std.debug.print("{d}", .{byte});
        if (line_len != 0 and (idx + 1) % line_len == 0) {
            std.debug.print("\n", .{});
        } else if (idx + 1 != buffer.len) {
            std.debug.print("{s}", .{separator});
        }
    }
    if (newline) {
        std.debug.print("\n", .{});
    }
}

pub fn print_timestamp(micros: u64) !void {
    // Convert microseconds to seconds
    const seconds: u64 = @divFloor(micros, 1_000_000);
    const remaining_micros = micros % 1_000_000;

    // Create EpochSeconds and get the day/time breakdown
    const epoch_seconds = std.time.epoch.EpochSeconds{ .secs = seconds };
    const epoch_day = epoch_seconds.getEpochDay();
    const day_seconds = epoch_seconds.getDaySeconds();

    const year_day = epoch_day.calculateYearDay();
    const month_day = year_day.calculateMonthDay();

    // Print human-readable format
    std.debug.print("{d}-{d:0>2}-{d:0>2} {d:0>2}:{d:0>2}:{d:0>2}.{d:0>6} UTC\n", .{
        year_day.year,
        month_day.month.numeric(),
        month_day.day_index + 1,
        day_seconds.getHoursIntoDay(),
        day_seconds.getMinutesIntoHour(),
        day_seconds.getSecondsIntoMinute(),
        remaining_micros,
    });
}
