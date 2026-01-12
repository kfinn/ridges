const std = @import("std");

const ezig_templates = @import("ezig_templates");
const mantle = @import("mantle");
const pg = @import("pg");

const tags = @import("../../../../relations/tags.zig");
const Context = @import("../../../../ridges.zig").App.ControllerContext;

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
    const tag = try context.repo.find(tags, params.id, .{});
    var response_writer = context.response.writer();
    try ezig_templates.@"api/tags-multi-select/v1/tags/show.json"(
        &response_writer.interface,
        .{ .tag = tag },
    );
}

const ChangeSet = struct {
    name: []const u8,
};

pub fn create(context: *Context) !void {
    if (try context.helpers.authenticateAdmin(.{}) == null) return;
    const tag = try mantle.forms.jsonDataProtectedFromForgery(context, ChangeSet) orelse return;
    const tag_create_result = try context.repo.create(tags, tag, .{});
    switch (tag_create_result) {
        .success => |created_tag| {
            var response_writer = context.response.writer();
            try ezig_templates.@"api/tags-multi-select/v1/tags/show.json"(
                &response_writer.interface,
                .{ .tag = created_tag },
            );
        },
        .failure => {
            context.response.status = 422;
        },
    }
}
