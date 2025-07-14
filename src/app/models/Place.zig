const ridges_lib = @import("ridges_lib");

const Point = @import("./Point.zig");

id: i64,
name: []const u8,
user_id: i64,
location: []const u8,

pub const Repo = ridges_lib.Repo(@This(), .{});

pub fn point(self: *const @This()) Point {
    return .fromEwkbPoint(self.location);
}
