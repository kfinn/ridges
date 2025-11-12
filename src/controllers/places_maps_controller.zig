const std = @import("std");

const ezig_templates = @import("ezig_templates");

const Context = @import("../ridges_app.zig").RidgesApp.ControllerContext;

pub fn show(context: *Context) !void {
    var response_writer = context.response.writer();
    try ezig_templates.@"layouts/app_layout.html"(
        &response_writer.interface,
        struct {
            pub fn writeBody(_: *const @This(), writer: *std.Io.Writer) !void {
                try ezig_templates.@"places_maps/show.html"(writer, .{});
            }
        }{},
    );
}
