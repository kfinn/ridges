const std = @import("std");

const ezig_templates = @import("ezig_templates");
const mantle = @import("mantle");

const tags = @import("../../relations/tags.zig");
const Context = @import("../../ridges.zig").App.ControllerContext;

pub fn index(context: *Context) !void {
    const admin = try context.helpers.authenticateAdmin(.{}) orelse return;

    const all_tags = try context.repo.all(tags, .{}, .{});
    var response_writer = context.response.writer();
    try ezig_templates.@"layouts/admin_layout.html"(
        &response_writer.interface,
        struct {
            admin: @TypeOf(admin),
            all_tags: @TypeOf(all_tags),

            pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                try ezig_templates.@"admin/tags/index.html"(
                    writer,
                    .{ .all_tags = self.all_tags },
                );
            }
        }{ .admin = admin, .all_tags = all_tags },
    );
}

const ChangeSet = struct {
    name: []const u8 = "",
};

pub fn new(context: *Context) !void {
    const admin = try context.helpers.authenticateAdmin(.{}) orelse return;

    const change_set: ChangeSet = .{};
    const form = mantle.forms.build(context, change_set, .{});
    var response_writer = context.response.writer();
    try ezig_templates.@"layouts/admin_layout.html"(
        &response_writer.interface,
        struct {
            admin: @TypeOf(admin),
            form: @TypeOf(form),

            pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                try ezig_templates.@"admin/tags/new.html"(
                    writer,
                    .{ .form = self.form },
                );
            }
        }{ .admin = admin, .form = form },
    );
}

pub fn create(context: *Context) !void {
    const admin = try context.helpers.authenticateAdmin(.{}) orelse return;

    const tag = try mantle.forms.formDataProtectedFromForgery(context, ChangeSet) orelse return;
    switch (try context.repo.create(tags, tag, .{})) {
        .success => {
            context.helpers.redirectTo("/tags");
            return;
        },
        .failure => |errors| {
            context.response.status = 422;
            const form = mantle.forms.build(context, tag, .{ .errors = errors });
            var response_writer = context.response.writer();
            try ezig_templates.@"layouts/admin_layout.html"(
                &response_writer.interface,
                struct {
                    admin: @TypeOf(admin),
                    form: @TypeOf(form),

                    pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                        try ezig_templates.@"admin/tags/new.html"(
                            writer,
                            .{ .form = self.form },
                        );
                    }
                }{ .admin = admin, .form = form },
            );
        },
    }
}
