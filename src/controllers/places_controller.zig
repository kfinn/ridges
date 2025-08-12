const std = @import("std");

const ezig_templates = @import("ezig_templates");
const httpz = @import("httpz");
const mantle = @import("mantle");

const Place = @import("../models/Place.zig");
const Context = @import("../ridges_app.zig").RidgesApp.ControllerContext;

pub fn index(context: *Context) !void {
    const places = try Place.Repo.all(context.db_conn, context.response.arena);

    context.response.status = 200;
    try ezig_templates.@"layouts/app_layout.html"(
        struct {
            places: []Place,

            pub fn writeBody(self: *const @This(), writer: std.io.AnyWriter) !void {
                try ezig_templates.@"places/index.html"(struct { places: []Place }, writer, .{ .places = self.places });
            }
        },
        context.response.writer().any(),
        .{ .places = places },
    );
}
