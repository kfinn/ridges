const std = @import("std");

const ezig_templates = @import("ezig_templates");
const httpz = @import("httpz");
const mantle = @import("mantle");
const pg = @import("pg");

const Point = @import("../models/Point.zig");
const Time = @import("../models/Time.zig");
const places = @import("../relations/places.zig");
const Context = @import("../ridges_app.zig").RidgesApp.ControllerContext;

pub fn index(context: *Context) !void {
    const all_places = try context.repo.all(places);
    var all_place_urls = try context.response.arena.alloc([]const u8, all_places.len);
    for (all_places, 0..) |place, place_index| {
        all_place_urls[place_index] = try std.fmt.allocPrint(context.response.arena, "/places/{s}", .{try pg.uuidToHex(place.attributes.id)});
    }

    var response_writer = context.response.writer();
    try ezig_templates.@"layouts/app_layout.html"(
        &response_writer.interface,
        struct {
            all_places: @TypeOf(all_places),
            all_place_urls: []const []const u8,

            pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                try ezig_templates.@"places/index.html"(
                    writer,
                    .{ .all_places = self.all_places, .all_place_urls = self.all_place_urls },
                );
            }
        }{ .all_places = all_places, .all_place_urls = all_place_urls },
    );
}

const ChangeSet = struct {
    name: []const u8 = "",
    location: struct {
        longitude: []const u8,
        latitude: []const u8,
    } = .{
        .longitude = "-73.9029527",
        .latitude = "40.7014435",
    },
    address: []const u8 = "",
    monday_opens_at: []const u8 = "",
    monday_open_seconds: []const u8 = "",
    tuesday_opens_at: []const u8 = "",
    tuesday_open_seconds: []const u8 = "",
    wednesday_opens_at: []const u8 = "",
    wednesday_open_seconds: []const u8 = "",
    thursday_opens_at: []const u8 = "",
    thursday_open_seconds: []const u8 = "",
    friday_opens_at: []const u8 = "",
    friday_open_seconds: []const u8 = "",
    saturday_opens_at: []const u8 = "",
    saturday_open_seconds: []const u8 = "",
    sunday_opens_at: []const u8 = "",
    sunday_open_seconds: []const u8 = "",

    pub fn fromPlace(place: anytype, allocator: std.mem.Allocator) !@This() {
        return .{
            .name = place.attributes.name,
            .location = .{
                .longitude = try std.fmt.allocPrint(allocator, "{d}", .{place.attributes.location.longitude}),
                .latitude = try std.fmt.allocPrint(allocator, "{d}", .{place.attributes.location.latitude}),
            },
            .address = place.attributes.address,
            .monday_opens_at = if (place.attributes.monday_opens_at) |monday_opens_at| try std.fmt.allocPrint(allocator, "{f}", .{monday_opens_at}) else "",
            .monday_open_seconds = try std.fmt.allocPrint(allocator, "{d}", .{place.attributes.monday_open_seconds}),
            .tuesday_opens_at = if (place.attributes.tuesday_opens_at) |tuesday_opens_at| try std.fmt.allocPrint(allocator, "{f}", .{tuesday_opens_at}) else "",
            .tuesday_open_seconds = try std.fmt.allocPrint(allocator, "{d}", .{place.attributes.tuesday_open_seconds}),
            .wednesday_opens_at = if (place.attributes.wednesday_opens_at) |wednesday_opens_at| try std.fmt.allocPrint(allocator, "{f}", .{wednesday_opens_at}) else "",
            .wednesday_open_seconds = try std.fmt.allocPrint(allocator, "{d}", .{place.attributes.wednesday_open_seconds}),
            .thursday_opens_at = if (place.attributes.thursday_opens_at) |thursday_opens_at| try std.fmt.allocPrint(allocator, "{f}", .{thursday_opens_at}) else "",
            .thursday_open_seconds = try std.fmt.allocPrint(allocator, "{d}", .{place.attributes.thursday_open_seconds}),
            .friday_opens_at = if (place.attributes.friday_opens_at) |friday_opens_at| try std.fmt.allocPrint(allocator, "{f}", .{friday_opens_at}) else "",
            .friday_open_seconds = try std.fmt.allocPrint(allocator, "{d}", .{place.attributes.friday_open_seconds}),
            .saturday_opens_at = if (place.attributes.saturday_opens_at) |saturday_opens_at| try std.fmt.allocPrint(allocator, "{f}", .{saturday_opens_at}) else "",
            .saturday_open_seconds = try std.fmt.allocPrint(allocator, "{d}", .{place.attributes.saturday_open_seconds}),
            .sunday_opens_at = if (place.attributes.sunday_opens_at) |sunday_opens_at| try std.fmt.allocPrint(allocator, "{f}", .{sunday_opens_at}) else "",
            .sunday_open_seconds = try std.fmt.allocPrint(allocator, "{d}", .{place.attributes.sunday_open_seconds}),
        };
    }

    pub fn format(self: *const @This(), writer: *std.Io.Writer) !void {
        try writer.print(
            \\.{{ .name = "{s}",
            \\.location = ("{s}", "{s}"),
            \\.address = "{s}",
            \\.monday_opens_at = "{s}",
            \\.monday_open_seconds = "{s}",
            \\.tuesday_opens_at = "{s}",
            \\.tuesday_open_seconds = "{s}",
            \\.wednesday_opens_at = "{s}",
            \\.wednesday_open_seconds = "{s}",
            \\.thursday_opens_at = "{s}",
            \\.thursday_open_seconds = "{s}",
            \\.friday_opens_at = "{s}",
            \\.friday_open_seconds = "{s}",
            \\.saturday_opens_at = "{s}",
            \\.saturday_open_seconds = "{s}",
            \\.sunday_opens_at = "{s}",
            \\.sunday_open_seconds = "{s}", }}
        , .{
            self.name,
            self.location.longitude,
            self.location.latitude,
            self.address,
            self.monday_opens_at,
            self.monday_open_seconds,
            self.tuesday_opens_at,
            self.tuesday_open_seconds,
            self.wednesday_opens_at,
            self.wednesday_open_seconds,
            self.thursday_opens_at,
            self.thursday_open_seconds,
            self.friday_opens_at,
            self.friday_open_seconds,
            self.saturday_opens_at,
            self.saturday_open_seconds,
            self.sunday_opens_at,
            self.sunday_open_seconds,
        });
    }

    const Self = @This();
    pub const casts = struct {
        pub fn location(change_set: Self, _: *const mantle.Repo, errors: *mantle.validation.RecordErrors(Self)) !Point {
            var opt_longitude: ?f32 = null;
            var opt_latitude: ?f32 = null;

            if (change_set.location.longitude.len == 0) {
                try errors.addFieldError(.location, .init(error.Required, "longitude required"));
            } else {
                if (std.fmt.parseFloat(f32, change_set.location.longitude)) |longitude| {
                    opt_longitude = longitude;
                } else |err| {
                    try errors.addFieldError(.location, .init(err, "longitude must be a number"));
                }
            }

            if (change_set.location.longitude.len == 0) {
                try errors.addFieldError(.location, .init(error.Required, "latitude required"));
            } else {
                if (std.fmt.parseFloat(f32, change_set.location.latitude)) |latitude| {
                    opt_latitude = latitude;
                } else |err| {
                    try errors.addFieldError(.location, .init(err, "latitude must be a number"));
                }
            }

            if (opt_longitude) |longitude| {
                if (opt_latitude) |latitude| {
                    return .{ .longitude = longitude, .latitude = latitude };
                }
            }
            return error.InvalidCast;
        }
    };
};

pub fn new(context: *Context) !void {
    const change_set: ChangeSet = .{};
    const form = mantle.forms.build(context, change_set, .{});
    var response_writer = context.response.writer();
    try ezig_templates.@"layouts/app_layout.html"(
        &response_writer.interface,
        struct {
            form: @TypeOf(form),

            pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                try ezig_templates.@"places/new.html"(
                    writer,
                    .{ .form = self.form },
                );
            }
        }{ .form = form },
    );
}

pub fn create(context: *Context) !void {
    const place = try mantle.forms.formDataProtectedFromForgery(context, ChangeSet) orelse return;
    switch (try context.repo.create(places, place)) {
        .success => |_| {
            context.helpers.redirectTo("/places");
            return;
        },
        .failure => |errors| {
            context.response.status = 422;
            const form = mantle.forms.build(context, place, .{ .errors = errors });
            var response_writer = context.response.writer();
            try ezig_templates.@"layouts/app_layout.html"(&response_writer.interface, struct {
                form: @TypeOf(form),

                pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                    try ezig_templates.@"places/new.html"(
                        writer,
                        .{ .form = self.form },
                    );
                }
            }{ .form = form });
        },
    }
}

pub fn show(context: *Context, params: struct { id: []const u8 }) !void {
    const place = try context.repo.find(places, params.id);
    const edit_place_url = try std.fmt.allocPrint(context.response.arena, "/places/{s}/edit", .{try pg.uuidToHex(place.attributes.id)});
    var response_writer = context.response.writer();
    try ezig_templates.@"layouts/app_layout.html"(
        &response_writer.interface,
        struct {
            place: @TypeOf(place),
            edit_place_url: []const u8,

            pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                try ezig_templates.@"places/show.html"(
                    writer,
                    .{ .place = self.place, .edit_place_url = self.edit_place_url },
                );
            }
        }{ .place = place, .edit_place_url = edit_place_url },
    );
}

pub fn edit(context: *Context, params: struct { id: []const u8 }) !void {
    const place = try context.repo.find(places, params.id);
    const place_url = try std.fmt.allocPrint(context.response.arena, "/places/{s}", .{try pg.uuidToHex(place.attributes.id)});
    const change_set = try ChangeSet.fromPlace(place, context.response.arena);
    const form = mantle.forms.build(context, change_set, .{});
    var response_writer = context.response.writer();
    try ezig_templates.@"layouts/app_layout.html"(
        &response_writer.interface,
        struct {
            place: @TypeOf(place),
            place_url: []const u8,
            form: @TypeOf(form),

            pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                try ezig_templates.@"places/edit.html"(
                    writer,
                    .{ .place = self.place, .place_url = self.place_url, .form = self.form },
                );
            }
        }{ .place = place, .place_url = place_url, .form = form },
    );
}

pub fn update(context: *Context, params: struct { id: []const u8 }) !void {
    const place = try context.repo.find(places, params.id);
    const place_url = try std.fmt.allocPrint(context.response.arena, "/places/{s}", .{try pg.uuidToHex(place.attributes.id)});
    const change_set = try mantle.forms.formDataProtectedFromForgery(context, ChangeSet) orelse return;

    switch (try context.repo.update(places, place, change_set)) {
        .success => |updated_place| {
            const updated_place_url = try std.fmt.allocPrint(context.response.arena, "/places/{s}", .{try pg.uuidToHex(updated_place.attributes.id)});
            context.helpers.redirectTo(updated_place_url);
            return;
        },
        .failure => |failure| {
            const failed_change_set = try ChangeSet.fromPlace(failure.record, context.response.arena);
            const form = mantle.forms.build(context, failed_change_set, .{ .errors = failure.errors });
            var response_writer = context.response.writer();
            try ezig_templates.@"layouts/app_layout.html"(
                &response_writer.interface,
                struct {
                    place: @TypeOf(place),
                    place_url: []const u8,
                    form: @TypeOf(form),

                    pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                        try ezig_templates.@"places/edit.html"(
                            writer,
                            .{ .place = self.place, .place_url = self.place_url, .form = self.form },
                        );
                    }
                }{ .place = place, .place_url = place_url, .form = form },
            );
        },
    }
}
