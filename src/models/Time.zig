const std = @import("std");

const mantle = @import("mantle");
const pg = @import("pg");

microseconds: i64,

pub fn writeHtmlTimeInputValue(self: *const @This(), writer: *std.Io.Writer) !void {
    const total_seconds = @divFloor(self.microseconds, 1000000);
    const seconds = @mod(total_seconds, 60);
    const total_minutes = @divFloor(total_seconds, 60);
    const minutes = @mod(total_minutes, 60);
    const hours = @divFloor(total_minutes, 60);

    if (hours > 10) {
        try writer.print("{d}", .{hours});
    } else {
        try writer.print("0{d}", .{hours});
    }
    try writer.writeByte(':');
    if (minutes > 10) {
        try writer.print("{d}", .{minutes});
    } else {
        try writer.print("0{d}", .{minutes});
    }
    try writer.writeByte(':');
    if (seconds > 10) {
        try writer.print("{d}", .{seconds});
    } else {
        try writer.print("0{d}", .{seconds});
    }
}

pub fn format(self: *const @This(), writer: *std.Io.Writer) std.Io.Writer.Error!void {
    try self.writeHtmlTimeInputValue(writer);
}

pub fn parseHtmlTimeInputValue(html_time_input_value: []const u8) !@This() {
    var split_iterator = std.mem.splitScalar(u8, html_time_input_value, ':');
    var split_index: usize = 0;
    var parsed_microseconds: i64 = 0;
    while (split_iterator.next()) |segment| {
        if (segment.len != 2) {
            return error.InvalidTimeFormat;
        }

        const segment_parsed_microseconds = try std.fmt.parseInt(i64, segment, 10);
        switch (split_index) {
            0 => {
                parsed_microseconds += segment_parsed_microseconds * 60 * 60 * 1000000;
            },
            1 => {
                parsed_microseconds += segment_parsed_microseconds * 60 * 1000000;
            },
            2 => {
                parsed_microseconds += segment_parsed_microseconds * 1000000;
            },
            else => {
                return error.InvalidTimeFormat;
            },
        }
        split_index += 1;
    }
    return .{ .microseconds = parsed_microseconds };
}

pub fn castFromInput(input_time: []const u8, _: *const mantle.Repo) !mantle.Repo.CastResult(@This()) {
    if (parseHtmlTimeInputValue(input_time)) |time| {
        return .{ .success = time };
    } else |err| {
        return .{ .failure = .init(err, "unable to parse Time") };
    }
}

pub fn isOptionalInputPresent(optional_input_time: []const u8) !bool {
    return optional_input_time.len > 0;
}

pub fn castFromDb(db_time: []const u8, _: anytype) !@This() {
    return .{ .microseconds = std.mem.readInt(i64, db_time[0..8], .big) };
}

pub fn castToDb(self: *const @This(), repo: *const mantle.Repo) !pg.Binary {
    const result = try repo.allocator.alloc(u8, 8);
    std.mem.writeInt(i64, result[0..8], self.microseconds, .big);
    return .{ .data = result };
}
