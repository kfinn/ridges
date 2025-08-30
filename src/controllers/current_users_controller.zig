const std = @import("std");

const ezig_templates = @import("ezig_templates");
const mantle = @import("mantle");

const users = @import("../relations//users.zig");
const Context = @import("../ridges_app.zig").RidgesApp.ControllerContext;

pub fn show(context: *Context) !void {
    if (try context.helpers.authenticateUser()) |user| {
        var response_writer = context.response.writer();
        try ezig_templates.@"layouts/app_layout.html"(
            &response_writer.interface,
            struct {
                user: @TypeOf(user),

                pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                    try ezig_templates.@"current_users/show.html"(
                        writer,
                        struct { user: @TypeOf(user) }{ .user = self.user },
                    );
                }
            }{ .user = user },
        );
    }
}

pub fn edit(context: *Context) !void {
    const user = try context.helpers.authenticateUser() orelse return;

    const form = mantle.forms.build(
        context,
        user.attributes,
        .{},
    );

    var response_writer = context.response.writer();
    try ezig_templates.@"layouts/app_layout.html"(
        &response_writer.interface,
        struct {
            form: @TypeOf(form),

            pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                try ezig_templates.@"current_users/edit.html"(
                    writer,
                    struct {
                        form: @TypeOf(form),
                    }{
                        .form = self.form,
                    },
                );
            }
        }{
            .form = form,
        },
    );
}

const UserUpdate = struct {
    name: []const u8 = "",
    email: []const u8 = "",
};

pub fn update(context: *Context) !void {
    const user = try context.helpers.authenticateUser() orelse return;
    const user_update = try mantle.forms.formDataProtectedFromForgery(context, UserUpdate) orelse return;
    switch (try context.repo.update(users, user, user_update)) {
        .success => |_| {
            context.helpers.redirectTo("/current_user");
            return;
        },
        .failure => |failure| {
            const form = mantle.forms.build(context, failure.record.attributes, .{ .errors = failure.errors });
            var response_writer = context.response.writer();
            try ezig_templates.@"layouts/app_layout.html"(
                &response_writer.interface,
                struct {
                    form: @TypeOf(form),

                    pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                        try ezig_templates.@"current_users/edit.html"(
                            writer,
                            struct {
                                form: @TypeOf(form),
                            }{
                                .form = self.form,
                            },
                        );
                    }
                }{
                    .form = form,
                },
            );
        },
    }
}
