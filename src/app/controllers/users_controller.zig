const std = @import("std");

const ezig_templates = @import("ezig_templates");
const httpz = @import("httpz");

const Context = @import("../RidgesApp.zig").RidgesApp.ControllerContext;

const User = struct {
    id: i64,
    name: []const u8,
};

pub fn show(context: *Context, params: struct { id: []const u8 }) !void {
    context.response.status = 200;

    const user = try (try context.db_conn.row("SELECT id, name FROM users WHERE id = $1", .{try std.fmt.parseInt(i64, params.id, 10)})).?.to(User, .{});

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
