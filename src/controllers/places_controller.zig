const std = @import("std");

const ezig_templates = @import("ezig_templates");
const httpz = @import("httpz");
const mantle = @import("mantle");

const Point = @import("../models/Point.zig");
const Time = @import("../models/Time.zig");
const places = @import("../relations/places.zig");
const Context = @import("../ridges_app.zig").RidgesApp.ControllerContext;

pub fn index(context: *Context) !void {
    const all_places = try context.repo.all(places);

    var response_writer = context.response.writer();
    try ezig_templates.@"layouts/app_layout.html"(
        &response_writer.interface,
        struct {
            all_places: @TypeOf(all_places),

            pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                try ezig_templates.@"places/index.html"(
                    writer,
                    .{ .all_places = self.all_places },
                );
            }
        }{ .all_places = all_places },
    );
}

const NewPlace = struct {
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
};

pub fn new(context: *Context) !void {
    const place: NewPlace = .{};
    const form = mantle.forms.build(context, place, .{});
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
    const place = try mantle.forms.formDataProtectedFromForgery(context, NewPlace) orelse return;
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
