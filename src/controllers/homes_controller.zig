const std = @import("std");

const ezig_templates = @import("ezig_templates");
const httpz = @import("httpz");

const Context = @import("../ridges_app.zig").RidgesApp.ControllerContext;

pub fn show(controller_context: *Context) !void {
    controller_context.response.status = 200;

    try ezig_templates.@"layouts/app_layout.html"(
        struct {
            pub fn writeBody(_: *const @This(), writer: std.io.AnyWriter) !void {
                try ezig_templates.@"homes/show.html"(struct {}, writer, .{});
            }
        },
        controller_context.response.writer().any(),
        .{},
    );
}
