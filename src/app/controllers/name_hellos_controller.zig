const std = @import("std");

const ezig_templates = @import("ezig_templates");
const httpz = @import("httpz");

const Context = @import("../RidgesApp.zig").RidgesApp.ControllerContext;

pub fn show(controller_context: *const Context, params: struct { name_id: []const u8 }) !void {
    controller_context.response.status = 200;

    try ezig_templates.@"layouts/app_layout.html"(
        struct {
            name_id: []const u8,

            pub fn writeTitle(self: *const @This(), writer: std.io.AnyWriter) !void {
                try writer.print("Hello, {s}!", .{self.name_id});
            }

            pub fn writeBody(self: *const @This(), writer: std.io.AnyWriter) !void {
                const BodyProps = struct {
                    name_id: []const u8,
                };
                try ezig_templates.@"name_hellos/show.html"(
                    BodyProps,
                    writer,
                    .{ .name_id = self.name_id },
                );
            }
        },
        controller_context.response.writer().any(),
        .{ .name_id = params.name_id },
    );
}
