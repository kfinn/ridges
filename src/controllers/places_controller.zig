const std = @import("std");

const ezig_templates = @import("ezig_templates");
const httpz = @import("httpz");
const mantle = @import("mantle");

const places = @import("../relations/places.zig");
const Context = @import("../ridges_app.zig").RidgesApp.ControllerContext;

pub fn index(context: *Context) !void {
    const all_places = try context.repo.all(places);

    context.response.status = 200;
    try ezig_templates.@"layouts/app_layout.html"(
        struct {
            all_places: []places.Place,

            pub fn writeBody(self: *const @This(), writer: std.io.AnyWriter) !void {
                try ezig_templates.@"places/index.html"(struct { all_places: []places.Place }, writer, .{ .all_places = self.all_places });
            }
        },
        context.response.writer().any(),
        .{ .all_places = all_places },
    );
}
