const std = @import("std");

const ridges_lib = @import("ridges_lib");
const ezig_templates = @import("ezig_templates");
const httpz = @import("httpz");

const Context = @import("../RidgesApp.zig").RidgesApp.ControllerContext;

const User = @import("../models/User.zig");

fn authenticateUser(context: *Context) !User {
    const session = context.session orelse return error.NoSession;
    return try User.Repo.find(context.db_conn, context.response.arena, session.user_id);
}

pub fn show(context: *Context) !void {
    const user = authenticateUser(context) catch {
        context.response.status = 303;
        context.response.header("Location", "/sessions/new");
        return;
    };

    context.response.status = 200;

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
