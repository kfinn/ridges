const mantle = @import("mantle");
const pg = @import("pg");

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

pub fn withAnyTagId(repo: *mantle.Repo, tag_ids: [][]const u8) !mantle.sql.Where(
    mantle.sql.ParameterizedSnippet("tag_id = ANY (?)", struct { pg.Binary }),
) {
    const uuid_array: mantle.UuidArray = .{ .uuids = tag_ids };
    return .{ .expression = .{ .params = .{try uuid_array.castToDb(repo)} } };
}
