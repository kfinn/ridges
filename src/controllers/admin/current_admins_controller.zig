const std = @import("std");

const ezig_templates = @import("ezig_templates");
const mantle = @import("mantle");

const admins = @import("../../relations/admins.zig");
const Context = @import("../../ridges.zig").App.ControllerContext;

pub fn show(context: *Context) !void {
    if (try context.helpers.authenticateAdmin(.{})) |admin| {
        var response_writer = context.response.writer();
        try ezig_templates.@"layouts/admin_layout.html"(
            &response_writer.interface,
            struct {
                admin: @TypeOf(admin),

                pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                    try ezig_templates.@"admin/current_admins/show.html"(
                        writer,
                        .{ .admin = self.admin },
                    );
                }
            }{ .admin = admin },
        );
    }
}

pub fn edit(context: *Context) !void {
    const admin = try context.helpers.authenticateAdmin(.{}) orelse return;

    const form = mantle.forms.build(
        context,
        admin.attributes,
        .{},
    );

    var response_writer = context.response.writer();
    try ezig_templates.@"layouts/admin_layout.html"(
        &response_writer.interface,
        struct {
            admin: @TypeOf(admin),
            form: @TypeOf(form),

            pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                try ezig_templates.@"admin/current_admins/edit.html"(
                    writer,
                    .{ .form = self.form },
                );
            }
        }{ .admin = admin, .form = form },
    );
}

const AdminUpdate = struct {
    name: []const u8 = "",
    email: []const u8 = "",

    pub fn fromAdmin(admin: anytype) @This() {
        return .{
            .name = admin.attributes.name,
            .email = admin.attributes.email,
        };
    }
};

pub fn update(context: *Context) !void {
    const admin = try context.helpers.authenticateAdmin(.{}) orelse return;
    const admin_update = try mantle.forms.formDataProtectedFromForgery(context, AdminUpdate) orelse return;
    switch (try context.repo.update(admin, admin_update)) {
        .success => |_| {
            context.helpers.redirectTo("/admin/current_admin");
            return;
        },
        .failure => |failure| {
            const form = mantle.forms.build(context, AdminUpdate.fromAdmin(failure.record), .{ .errors = failure.errors });
            var response_writer = context.response.writer();
            try ezig_templates.@"layouts/admin_layout.html"(
                &response_writer.interface,
                struct {
                    admin: @TypeOf(admin),
                    form: @TypeOf(form),

                    pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                        try ezig_templates.@"admin/current_admins/edit.html"(
                            writer,
                            .{ .form = self.form },
                        );
                    }
                }{ .admin = admin, .form = form },
            );
        },
    }
}
