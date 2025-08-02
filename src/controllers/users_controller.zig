const std = @import("std");

const mantle = @import("mantle");
const ezig_templates = @import("ezig_templates");
const httpz = @import("httpz");

const Context = @import("../ridges_app.zig").RidgesApp.ControllerContext;

const User = @import("../models/User.zig");
const PasswordConfirmation = @import("../models/PasswordConfirmation.zig");

pub fn show(context: *Context, params: struct { id: []const u8 }) !void {
    context.response.status = 200;

    const user = try User.Repo.find(context.db_conn, context.response.arena, try std.fmt.parseInt(i64, params.id, 10));

    try ezig_templates.@"layouts/app_layout.html"(
        struct {
            user: User,

            pub fn writeBody(self: *const @This(), writer: std.io.AnyWriter) !void {
                try ezig_templates.@"users/show.html"(
                    struct {
                        user: User,
                    },
                    writer,
                    .{ .user = self.user },
                );
            }
        },
        context.response.writer().any(),
        .{ .user = user },
    );
}

const NewProps = struct {
    user: User.Repo.NewRecord,
    user_errors: ?mantle.validation.RecordErrors(User.Repo.NewRecord) = null,
    password_confirmation_errors: ?mantle.validation.RecordErrors(PasswordConfirmation) = null,
};

pub fn new(context: *Context) !void {
    const user: User.Repo.NewRecord = .{
        .name = "",
        .email = "",
        .password_bcrypt = "",
    };

    context.response.status = 200;

    try ezig_templates.@"layouts/app_layout.html"(
        struct {
            user: User.Repo.NewRecord,

            pub fn writeBody(self: *const @This(), writer: std.io.AnyWriter) !void {
                try ezig_templates.@"users/new.html"(NewProps, writer, .{ .user = self.user });
            }
        },
        context.response.writer().any(),
        .{
            .user = user,
        },
    );
}

pub fn create(context: *Context) !void {
    const form_data = try context.request.formData();
    const password_confirmation = PasswordConfirmation.fromFormData(form_data);
    var password_confirmation_errors = try password_confirmation.validate(context.response.arena);

    const user: User.Repo.NewRecord = .{
        .name = form_data.get("name") orelse "",
        .email = form_data.get("email") orelse "",
        .password_bcrypt = if (password_confirmation_errors.isValid()) try password_confirmation.toPasswordHash(context.response.arena) else "",
    };
    const user_errors = try User.Repo.validate(context.response.arena, user);

    if (user_errors.isValid() and password_confirmation_errors.isValid()) {
        const created_user = try User.Repo.create(context.db_conn, context.response.arena, user);

        context.response.status = 303;
        context.response.header("Location", try std.fmt.allocPrint(context.response.arena, "/users/{d}", .{created_user.id}));
    } else {
        context.response.status = 422;
        try ezig_templates.@"layouts/app_layout.html"(struct {
            user: User.Repo.NewRecord,
            user_errors: User.Repo.NewRecordErrors,
            password_confirmation_errors: PasswordConfirmation.Errors,

            pub fn writeBody(self: *const @This(), writer: std.io.AnyWriter) !void {
                try ezig_templates.@"users/new.html"(NewProps, writer, .{
                    .user = self.user,
                    .user_errors = self.user_errors,
                    .password_confirmation_errors = self.password_confirmation_errors,
                });
            }
        }, context.response.writer().any(), .{
            .user = user,
            .user_errors = user_errors,
            .password_confirmation_errors = password_confirmation_errors,
        });
    }
}
