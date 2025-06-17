const std = @import("std");

const ezig_templates = @import("ezig_templates");
const httpz = @import("httpz");

const Context = @import("../RidgesApp.zig").RidgesApp.ControllerContext;

pub fn show(controller_context: *const Context) !void {
    controller_context.response.status = 200;

    const Props = struct {
        pub fn writeBody(_: *const @This(), writer: std.io.AnyWriter) !void {
            try ezig_templates.@"homes/show.html"(struct {}, writer, .{});
        }
    };
    try ezig_templates.@"layouts/app_layout.html"(Props, controller_context.response.writer().any(), .{});
}
