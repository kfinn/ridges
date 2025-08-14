const std = @import("std");

const ezig_templates = @import("ezig_templates");
const httpz = @import("httpz");
const mantle = @import("mantle");

const User = @import("../models/User.zig");
const Context = @import("../ridges_app.zig").RidgesApp.ControllerContext;

const Session = struct {
    email: ?[]const u8,
    password: ?[]const u8,

    fn validate(self: *const @This(), allocator: std.mem.Allocator) !mantle.validation.RecordErrors(@This()) {
        var errors = mantle.validation.RecordErrors(@This()).init(allocator);

        if (self.email) |email| {
            if (email.len == 0) {
                try errors.addFieldError(.email, .init(error.Required, "required"));
            }
        } else {
            try errors.addFieldError(.email, .init(error.Required, "required"));
        }
        if (self.password) |password| {
            if (password.len == 0) {
                try errors.addFieldError(.password, .init(error.Required, "required"));
            }
        } else {
            try errors.addFieldError(.email, .init(error.Required, "required"));
        }

        return errors;
    }
};

pub fn new(context: *Context) !void {
    context.response.status = 200;

    try ezig_templates.@"layouts/app_layout.html"(
        struct {
            pub fn writeBody(_: *const @This(), writer: std.io.AnyWriter) !void {
                try ezig_templates.@"sessions/new.html"(
                    struct { email: []const u8, errors: ?mantle.validation.RecordErrors(Session) },
                    writer,
                    .{ .email = "", .errors = null },
                );
            }
        },
        context.response.writer().any(),
        .{},
    );
}

pub fn create(context: *Context) !void {
    const form_data = try context.request.formData();
    var errors = mantle.validation.RecordErrors(Session).init(context.response.arena);
    if (mantle.form_data.parse(Session, form_data, mantle.form_data.empty_prefix)) |new_session| {
        errors = try new_session.validate(context.response.arena);
        if (errors.isValid()) {
            if (try User.Repo.findBy(context.db_conn, context.response.arena, .{ .email = new_session.email.? })) |user| {
                if (user.authenticatePassword(new_session.password.?)) {
                    context.session = .{ .user_id = user.id[0..16].* };

                    context.response.status = 302;
                    context.response.header("Location", "/current_user");
                    return;
                } else {
                    try errors.addFieldError(.password, .init(error.InvalidPassword, "invalid password"));
                }
            } else {
                try errors.addFieldError(.email, .init(error.NotFound, "not found"));
            }
        }
    } else |err| {
        errors.addBaseError(.init(err, "unknonwn error"));
    }

    try ezig_templates.@"layouts/app_layout.html"(
        struct {
            errors: mantle.validation.RecordErrors(Session),
            email: []const u8,

            pub fn writeBody(self: *const @This(), writer: std.io.AnyWriter) !void {
                try ezig_templates.@"sessions/new.html"(
                    struct { errors: ?mantle.validation.RecordErrors(Session), email: []const u8 },
                    writer,
                    .{ .errors = self.errors, .email = self.email },
                );
            }
        },
        context.response.writer().any(),
        .{ .email = form_data.get("email") orelse "", .errors = errors },
    );
}
