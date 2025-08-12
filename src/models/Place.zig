const mantle = @import("mantle");

const Point = @import("./Point.zig");

id: i64,
name: []const u8,
location: []const u8,
description: []const u8 = "",

pub const Repo = mantle.Repo(@This(), .{});

pub fn point(self: *const @This()) Point {
    return .fromEwkbPoint(self.location);
}
