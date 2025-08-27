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
                user: users.User,

                pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) std.Io.Writer.Error!void {
                    try ezig_templates.@"current_users/show.html"(
                        writer,
                        struct { user: users.User }{ .user = self.user },
                    );
                }
            }{ .user = user },
        );
    }
}

pub fn edit(context: *Context) !void {
    if (try context.helpers.authenticateUser()) |user| {
        var errors: mantle.validation.RecordErrors(users.User) = .init(context.request.arena);
        var response_writer = context.response.writer();
        try ezig_templates.@"layouts/app_layout.html"(
            &response_writer.interface,
            struct {
                user: users.User,
                errors: *mantle.validation.RecordErrors(users.User),

                pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) std.Io.Writer.Error!void {
                    try ezig_templates.@"current_users/edit.html"(
                        writer,
                        struct {
                            user: users.User,
                            errors: *mantle.validation.RecordErrors(users.User),
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
    if (try context.helpers.authenticateUser()) |user| {
        var updated_user = user;
        const form_data = try context.request.formData();
        var errors: mantle.validation.RecordErrors(users.User) = .init(context.response.arena);
        if (mantle.form_data.parse(UserUpdate, form_data, mantle.form_data.empty_prefix)) |user_update| {
            updated_user.name = user_update.name;
            updated_user.email = user_update.email;
            if (context.repo.update(users, updated_user)) |_| {
                context.helpers.redirectTo("/current_user");
                return;
            } else |err| {
                std.log.info("error: {any}", .{err});
                try users.validate(updated_user, &errors);
                try errors.addBaseError(.init(err, "something went wrong"));
            }
        } else |err| {
            try errors.addBaseError(.init(err, "unknown error"));
        }

        var response_writer = context.response.writer();
        try ezig_templates.@"layouts/app_layout.html"(
            &response_writer.interface,
            struct {
                user: users.User,
                errors: *mantle.validation.RecordErrors(users.User),

                pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) std.Io.Writer.Error!void {
                    try ezig_templates.@"current_users/edit.html"(
                        writer,
                        struct {
                            user: users.User,
                            errors: *mantle.validation.RecordErrors(users.User),
                        }{
                            .user = self.user,
                            .errors = self.errors,
                        },
                    );
                }
            }{
                .user = updated_user,
                .errors = &errors,
            },
        );
    }
}
