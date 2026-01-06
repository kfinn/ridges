const std = @import("std");

const ezig_templates = @import("ezig_templates");
const httpz = @import("httpz");
const mantle = @import("mantle");

const admins = @import("../../relations/admins.zig");
const Context = @import("../../ridges.zig").App.ControllerContext;

pub fn new(context: *Context) !void {
    context.response.status = 200;

    const session: admins.NewSession = .{};
    const form = mantle.forms.build(context, session, .{});
    var response_writer = context.response.writer();
    try ezig_templates.@"layouts/app_layout.html"(
        &response_writer.interface,
        struct {
            form: @TypeOf(form),

            pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                try ezig_templates.@"admin/sessions/new.html"(
                    writer,
                    .{ .form = self.form },
                );
            }
        }{ .form = form },
    );
}

pub fn create(context: *Context) !void {
    const session = try mantle.forms.formDataProtectedFromForgery(context, admins.NewSession) orelse return;
    switch (try admins.authenticate(context.response.arena, &context.repo, session)) {
        .success => |admin| {
            context.session.admin_id = admin.attributes.id[0..16].*;
            context.helpers.redirectTo("/admin");
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
                        try ezig_templates.@"admin/sessions/new.html"(
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
