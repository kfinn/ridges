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

    const session: users.NewSession = .{};
    const form = mantle.forms.build(context, session, .{});
    var response_writer = context.response.writer();
    try ezig_templates.@"layouts/app_layout.html"(
        &response_writer.interface,
        struct {
            form: @TypeOf(form),

            pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                try ezig_templates.@"sessions/new.html"(
                    writer,
                    .{ .form = self.form },
                );
            }
        }{ .form = form },
    );
}

pub fn create(context: *Context) !void {
    const session = try mantle.forms.formDataProtectedFromForgery(context, users.NewSession) orelse return;
    switch (try users.authenticate(context.response.arena, &context.repo, session)) {
        .success => {
            context.helpers.redirectTo("/current_user");
            return;
        },
        .failure => |errors| {
            const form = mantle.forms.build(context, session, .{ .errors = errors });

            context.response.status = 422;
            var response_writer = context.response.writer();
            try ezig_templates.@"layouts/app_layout.html"(
                &response_writer.interface,
                struct {
                    form: @TypeOf(form),

                    pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                        try ezig_templates.@"sessions/new.html"(
                            writer,
                            .{ .form = self.form },
                        );
                    }
                }{
                    .form = form,
                },
            );
        },
    }
}
