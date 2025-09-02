const std = @import("std");

const mantle = @import("mantle");
const pg = @import("pg");

const Point = @import("../models/Point.zig");

pub const from_db_casts = struct {
    pub fn location(db_value: []const u8, repo: *const mantle.Repo) !Point {
        _ = repo;
        return Point.fromEwkbPoint(db_value);
    }
};

pub const to_db_casts = struct {
    pub fn location(value: Point, repo: *const mantle.Repo) !pg.Binary {
        const ewkb_point = value.toEwkbPoint();
        const result = try repo.allocator.alloc(u8, ewkb_point.len);
        @memcpy(result, &ewkb_point);
        return .{ .data = result };
    }
};

pub const Attributes = struct {
    id: []const u8,
    name: []const u8,
    location: Point,
    description: []const u8 = "",
};

pub fn validate(self: anytype, errors: *mantle.validation.RecordErrors(@TypeOf(self))) !void {
    if (self.name.len == 0) {
        try errors.addFieldError(.name, .init(error.Required, "required"));
    }
    if (self.description.len == 0) {
        try errors.addFieldError(.description, .init(error.Required, "required"));
    }
}
