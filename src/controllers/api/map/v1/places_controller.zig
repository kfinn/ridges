const std = @import("std");

const ezig_templates = @import("ezig_templates");
const mantle = @import("mantle");
const pg = @import("pg");

const Bounds = @import("../../../../models/Bounds.zig");
const places = @import("../../../../relations/places.zig");
const Context = @import("../../../../ridges.zig").App.ControllerContext;

const Filter = struct {
    inBounds: ?struct {
        north: []const u8,
        east: []const u8,
        south: []const u8,
        west: []const u8,

        fn toBounds(self: *const @This()) !Bounds {
            return .{
                .west = try std.fmt.parseFloat(f64, self.west),
                .south = try std.fmt.parseFloat(f64, self.south),
                .east = try std.fmt.parseFloat(f64, self.east),
                .north = try std.fmt.parseFloat(f64, self.north),
            };
        }

        pub fn format(self: *const @This(), writer: *std.Io.Writer) !void {
            return writer.print("({s} {s} {s} {s})", .{ self.west, self.south, self.east, self.north });
        }
    } = null,
};

pub fn index(context: *Context) !void {
    const filter = try mantle.url_form_encoded.parse(Filter, try context.request.query());

    const all_places = all_places: {
        if (filter.inBounds) |inBounds| {
            break :all_places try context.repo.all(places, .{ .where = try places.inBounds(&context.repo, try inBounds.toBounds()) }, .{});
        } else {
            break :all_places try context.repo.all(places, .{}, .{});
        }
    };
    var all_place_urls = try context.response.arena.alloc([]const u8, all_places.len);
    for (all_places, 0..) |place, place_index| {
        all_place_urls[place_index] = try std.fmt.allocPrint(context.response.arena, "/admin/places/{s}", .{try pg.uuidToHex(place.attributes.id)});
    }
    var response_writer = context.response.writer();
    try ezig_templates.@"api/map/v1/places/index.json"(
        &response_writer.interface,
        .{ .all_places = all_places, .all_place_urls = all_place_urls },
    );
}
