const std = @import("std");

const ezig_templates = @import("ezig_templates");
const httpz = @import("httpz");

const Context = @import("../RidgesApp.zig").RidgesApp.ControllerContext;

const Place = @import("../models/Place.zig");

pub fn index(context: *Context) !void {
    context.response.status = 200;

    const places = try Place.Repo.all(context.db_conn, context.response.arena);

    try ezig_templates.@"layouts/app_layout.html"(
        struct {
            places: []Place,

            pub fn writeBody(self: *const @This(), writer: std.io.AnyWriter) !void {
                try ezig_templates.@"places/index.html"(
                    struct {
                        places: []Place,
                    },
                    writer,
                    .{ .places = self.places },
                );
            }
        },
        context.response.writer().any(),
        .{ .places = places },
    );
}
