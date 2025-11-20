const std = @import("std");

const ezig_templates = @import("ezig_templates");
const mantle = @import("mantle");

const tags = @import("../relations/tags.zig");
const Context = @import("../ridges_app.zig").RidgesApp.ControllerContext;

pub fn index(context: *Context) !void {
    const all_tags = try context.repo.all(tags, .{}, .{});
    var response_writer = context.response.writer();
    try ezig_templates.@"layouts/app_layout.html"(
        &response_writer.interface,
        struct {
            all_tags: @TypeOf(all_tags),

            pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                try ezig_templates.@"tags/index.html"(
                    writer,
                    .{ .all_tags = self.all_tags },
                );
            }
        }{ .all_tags = all_tags },
    );
}

const ChangeSet = struct {
    name: []const u8 = "",
};

pub fn new(context: *Context) !void {
    const change_set: ChangeSet = .{};
    const form = mantle.forms.build(context, change_set, .{});
    var response_writer = context.response.writer();
    try ezig_templates.@"layouts/app_layout.html"(
        &response_writer.interface,
        struct {
            form: @TypeOf(form),

            pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                try ezig_templates.@"tags/new.html"(
                    writer,
                    .{ .form = self.form },
                );
            }
        }{ .form = form },
    );
}

pub fn create(context: *Context) !void {
    const tag = try mantle.forms.formDataProtectedFromForgery(context, ChangeSet) orelse return;
    switch (try context.repo.create(tags, tag)) {
        .success => {
            context.helpers.redirectTo("/tags");
            return;
        },
        .failure => |errors| {
            context.response.status = 422;
            const form = mantle.forms.build(context, tag, .{ .errors = errors });
            var response_writer = context.response.writer();
            try ezig_templates.@"layouts/app_layout.html"(
                &response_writer.interface,
                struct {
                    form: @TypeOf(form),

                    pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                        try ezig_templates.@"tags/new.html"(
                            writer,
                            .{ .form = self.form },
                        );
                    }
                }{ .form = form },
            );
        },
    }
}
