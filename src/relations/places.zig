const mantle = @import("mantle");

const Point = @import("../models/Point.zig");

pub const Attributes = struct {
    id: []const u8,
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

pub fn validate(self: anytype, errors: *mantle.validation.RecordErrors(@TypeOf(self))) !void {
    if (self.name.len == 0) {
        try errors.addFieldError(.name, .init(error.Required, "required"));
    }
    if (self.description.len == 0) {
        try errors.addFieldError(.description, .init(error.Required, "required"));
    }
    if (self.location.len == 0) {
        try errors.addFieldError(.location, .init(error.Required, "required"));
    }
}
