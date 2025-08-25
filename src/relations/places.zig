const mantle = @import("mantle");

const Point = @import("../models/Point.zig");

pub const Place = struct {
    id: i64,
    name: []const u8,
    location: []const u8,
    description: []const u8 = "",

    pub fn point(self: *const @This()) Point {
        return .fromEwkbPoint(self.location);
    }
};
pub const Record = Place;
