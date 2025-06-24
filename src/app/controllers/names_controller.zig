const std = @import("std");

const ezig_templates = @import("ezig_templates");
const httpz = @import("httpz");

const Context = @import("../RidgesApp.zig").RidgesApp.ControllerContext;

pub fn show(context: *const Context, params: struct { id: []const u8 }) !void {
    context.response.status = 200;

    try ezig_templates.@"layouts/app_layout.html"(
        struct {
            id: []const u8,

            pub fn writeBody(self: *const @This(), writer: std.io.AnyWriter) !void {
                const BodyProps = struct { id: []const u8 };
                try ezig_templates.@"names/show.html"(BodyProps, writer, .{ .id = self.id });
            }
        },
        context.response.writer().any(),
        .{ .id = params.id },
    );
}
