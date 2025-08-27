const std = @import("std");

const ezig_templates = @import("ezig_templates");
const httpz = @import("httpz");
const mantle = @import("mantle");

const users = @import("../relations/users.zig");
const Context = @import("../ridges_app.zig").RidgesApp.ControllerContext;

const Session = struct {
    email: ?[]const u8,
    password: ?[]const u8,

    fn validate(self: *const @This(), errors: *mantle.validation.RecordErrors(@This())) !void {
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
    }
};

pub fn new(context: *Context) !void {
    context.response.status = 200;

    var response_writer = context.response.writer();
    try ezig_templates.@"layouts/app_layout.html"(
        &response_writer.interface,
        struct {
            pub fn writeBody(_: *const @This(), writer: *std.Io.Writer) std.Io.Writer.Error!void {
                try ezig_templates.@"sessions/new.html"(
                    writer,
                    struct { email: []const u8, errors: ?mantle.validation.RecordErrors(Session) }{
                        .email = "",
                        .errors = null,
                    },
                );
            }
        }{},
    );
}

pub fn create(context: *Context) !void {
    const form_data = try context.request.formData();
    var errors: mantle.validation.RecordErrors(Session) = .init(context.response.arena);
    if (mantle.form_data.parse(Session, form_data, mantle.form_data.empty_prefix)) |new_session| {
        try new_session.validate(&errors);
        if (errors.isValid()) {
            if (try context.repo.findBy(users, .{ .email = new_session.email.? })) |user| {
                if (users.authenticatePassword(user, new_session.password.?)) {
                    context.session = .{ .user_id = user.id[0..16].* };

                    context.helpers.redirectTo("/current_user");
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

    context.response.status = 422;
    var response_writer = context.response.writer();
    try ezig_templates.@"layouts/app_layout.html"(
        &response_writer.interface,
        struct {
            errors: mantle.validation.RecordErrors(Session),
            email: []const u8,

            pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                try ezig_templates.@"sessions/new.html"(
                    writer,
                    struct {
                        errors: ?mantle.validation.RecordErrors(Session),
                        email: []const u8,
                    }{
                        .errors = self.errors,
                        .email = self.email,
                    },
                );
            }
        }{
            .email = form_data.get("email") orelse "",
            .errors = errors,
        },
    );
}
