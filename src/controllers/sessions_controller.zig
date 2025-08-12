const std = @import("std");

const ezig_templates = @import("ezig_templates");
const httpz = @import("httpz");
const mantle = @import("mantle");

const User = @import("../models/User.zig");
const Context = @import("../ridges_app.zig").RidgesApp.ControllerContext;

const Session = struct {
    email: []const u8,
    password: []const u8,

    const empty = .{ .email = "", .password = "" };

    fn fromFormData(form_data: anytype) !@This() {
        return .{
            .email = form_data.get("email") orelse return error.InvalidFormData,
            .password = form_data.get("password") orelse return error.InvalidFormData,
        };
    }
};

pub fn new(context: *Context) !void {
    context.response.status = 200;

    try ezig_templates.@"layouts/app_layout.html"(
        struct {
            pub fn writeBody(_: *const @This(), writer: std.io.AnyWriter) !void {
                try ezig_templates.@"sessions/new.html"(
                    struct { email: []const u8, failed: bool },
                    writer,
                    .{ .email = "", .failed = false },
                );
            }
        },
        context.response.writer().any(),
        .{},
    );
}

pub fn create(context: *Context) !void {
    const form_data = try context.request.formData();
    if (mantle.form_data.parse(Session, form_data, mantle.form_data.empty_prefix)) |new_session| {
        if (try User.Repo.findBy(context.db_conn, context.response.arena, .{ .email = new_session.email })) |user| {
            if (user.authenticatePassword(new_session.password)) {
                context.session = .{ .user_id = user.id };

                context.response.status = 302;
                context.response.header("Location", "/current_user");
                return;
            }
        }
    } else |_| {}

    try ezig_templates.@"layouts/app_layout.html"(
        struct {
            email: []const u8,

            pub fn writeBody(self: *const @This(), writer: std.io.AnyWriter) !void {
                try ezig_templates.@"sessions/new.html"(
                    struct { email: []const u8, failed: bool },
                    writer,
                    .{ .email = self.email, .failed = true },
                );
            }
        },
        context.response.writer().any(),
        .{ .email = form_data.get("email") orelse "" },
    );
}
