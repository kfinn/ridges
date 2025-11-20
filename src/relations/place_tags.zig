const mantle = @import("mantle");

pub const Attributes = struct {
    id: []const u8,
    place_id: []const u8,
    tag_id: []const u8,
};

pub const associations = &[_]mantle.Association{
    .belongsTo(@import("places.zig")),
    .belongsTo(@import("tags.zig")),
};

pub fn validate(self: anytype, errors: *mantle.validation.RecordErrors(@TypeOf(self))) !void {
    try mantle.validation.validatePresence(self, &.{ .place_id, .tag_id }, errors);
}
