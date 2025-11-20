const std = @import("std");

const ezig_templates = @import("ezig_templates");
const mantle = @import("mantle");
const pg = @import("pg");

const tags = @import("../../../../relations/tags.zig");
const Context = @import("../../../../ridges_app.zig").RidgesApp.ControllerContext;

const Filter = struct {
    q: ?[]const u8 = null,
};

pub fn index(context: *Context) !void {
    const filter = try mantle.url_form_encoded.parse(Filter, try context.request.query());

    const all_tags = all_tags: {
        if (filter.q) |q| {
            break :all_tags try context.repo.all(tags, .{ .where = tags.matchingQuery(&context.repo, q), .limit = 10 }, .{});
        } else {
            break :all_tags try context.repo.all(tags, .{ .limit = 10 }, .{});
        }
    };

    var response_writer = context.response.writer();
    try ezig_templates.@"api/tags-multi-select/v1/tags/index.json"(
        &response_writer.interface,
        .{ .all_tags = all_tags },
    );
}

pub fn show(context: *Context, params: struct { id: []const u8 }) !void {
    const tag = try context.repo.find(tags, params.id);
    var response_writer = context.response.writer();
    try ezig_templates.@"api/tags-multi-select/v1/tags/show.json"(
        &response_writer.interface,
        .{ .tag = tag },
    );
}
