const std = @import("std");

const ezig_templates = @import("ezig_templates");
const httpz = @import("httpz");
const mantle = @import("mantle");

const places = @import("../relations/places.zig");
const Context = @import("../ridges_app.zig").RidgesApp.ControllerContext;

pub fn index(context: *Context) !void {
    const all_places = try context.repo.all(places);

    var response_writer = context.response.writer();
    context.response.status = 200;
    try ezig_templates.@"layouts/app_layout.html"(
        &response_writer.interface,
        struct {
            all_places: @TypeOf(all_places),

            pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) std.Io.Writer.Error!void {
                try ezig_templates.@"places/index.html"(writer, struct {
                    all_places: @TypeOf(all_places),
                }{
                    .all_places = self.all_places,
                });
            }
        }{ .all_places = all_places },
    );
}
