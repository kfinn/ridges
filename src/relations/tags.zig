const mantle = @import("mantle");

pub const Attributes = struct {
    id: []const u8,
    name: []const u8,
};

pub const associations = &[_]mantle.Association{
    .hasMany(@import("place_tags.zig")),
};

pub fn validate(self: anytype, errors: *mantle.validation.RecordErrors(@TypeOf(self))) !void {
    try mantle.validation.validatePresence(self, &.{.name}, errors);
}

pub fn matchingQuery(
    _: *mantle.Repo,
    query: []const u8,
) mantle.sql.Where(
    mantle.sql.ParameterizedSnippet(
        "starts_with(lower(regexp_replace(name, '\\s', '', 'g')), lower(regexp_replace(?, '\\s', '', 'g')))",
        struct { []const u8 },
    ),
) {
    return .{ .expression = .{ .params = .{query} } };
}
