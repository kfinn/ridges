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

                pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) std.Io.Writer.Error!void {
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
    if (try context.helpers.authenticateUser()) |user| {
        var errors: mantle.validation.RecordErrors(@TypeOf(user.attributes)) = .init(context.request.arena);
        var response_writer = context.response.writer();
        try ezig_templates.@"layouts/app_layout.html"(
            &response_writer.interface,
            struct {
                user: @TypeOf(user),
                errors: *const mantle.validation.RecordErrors(@TypeOf(user.attributes)),

                pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) std.Io.Writer.Error!void {
                    try ezig_templates.@"current_users/edit.html"(
                        writer,
                        struct {
                            user: @TypeOf(user),
                            errors: *const mantle.validation.RecordErrors(@TypeOf(user.attributes)),
                        }{
                            .user = self.user,
                            .errors = self.errors,
                        },
                    );
                }
            }{
                .user = user,
                .errors = &errors,
            },
        );
    }
}

const UserUpdate = struct {
    name: []const u8,
    email: []const u8,
};

pub fn update(context: *Context) !void {
    var user = try context.helpers.authenticateUser() orelse return;
    var errors: mantle.validation.RecordErrors(@TypeOf(user.attributes)) = undefined;
    if (mantle.form_data.parse(UserUpdate, try context.request.formData(), mantle.form_data.empty_prefix)) |user_update| {
        switch (try context.repo.update(users, user, user_update)) {
            .success => |_| {
                context.helpers.redirectTo("/current_user");
                return;
            },
            .failure => |failure| {
                errors = failure.errors;
                user = failure.record;
            },
        }
    } else |err| {
        errors = .init(context.response.arena);
        try errors.addBaseError(.init(err, "unknown error"));
    }

    var response_writer = context.response.writer();
    try ezig_templates.@"layouts/app_layout.html"(
        &response_writer.interface,
        struct {
            user: @TypeOf(user),
            errors: *const mantle.validation.RecordErrors(@TypeOf(user.attributes)),

            pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) std.Io.Writer.Error!void {
                try ezig_templates.@"current_users/edit.html"(
                    writer,
                    struct {
                        user: @TypeOf(user),
                        errors: *const mantle.validation.RecordErrors(@TypeOf(user.attributes)),
                    }{
                        .user = self.user,
                        .errors = self.errors,
                    },
                );
            }
        }{
            .user = user,
            .errors = &errors,
        },
    );
}
