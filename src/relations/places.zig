const mantle = @import("mantle");

const Point = @import("../models/Point.zig");

pub const Attributes = struct {
    id: i64,
    name: []const u8,
    location: []const u8,
    description: []const u8 = "",
};

pub fn helpers(comptime Result: type, comptime field_name: []const u8) type {
    return struct {
        fn place(self: *const @This()) *const Result {
            return @alignCast(@fieldParentPtr(field_name, self));
        }

        pub fn point(self: *const @This()) Point {
            return .fromEwkbPoint(self.place().attributes.location);
        }
    };
}
