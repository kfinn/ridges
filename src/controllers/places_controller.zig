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
    const NewPlaceSelf = @This();
    const Location = struct {
        longitude: []const u8,
        latitude: []const u8,
    };

    name: []const u8 = "",
    location: Location = .{
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

    pub const casts = struct {
        pub fn location(new_place: NewPlaceSelf, repo: *const mantle.Repo, errors: *mantle.validation.RecordErrors(NewPlaceSelf)) !mantle.Repo.CastResult(Point) {
            _ = repo;
            const latitude = std.fmt.parseFloat(f64, new_place.location.latitude) catch |err| {
                try errors.addFieldError(.location, .init(err, "invalid"));
                return .failure;
            };
            const longitude = std.fmt.parseFloat(f64, new_place.location.longitude) catch |err| {
                try errors.addFieldError(.location, .init(err, "invalid"));
                return .failure;
            };
            return .{ .success = .{ .latitude = latitude, .longitude = longitude } };
        }

        pub fn monday_opens_at(new_place: NewPlaceSelf, repo: *const mantle.Repo, errors: *mantle.validation.RecordErrors(NewPlaceSelf)) !mantle.Repo.CastResult(?Time) {
            _ = repo;

            if (new_place.monday_opens_at.len == 0) {
                return .{ .success = null };
            }
            if (Time.parseHtmlTimeInputValue(new_place.monday_opens_at)) |time| {
                return .{ .success = time };
            } else |err| {
                try errors.addFieldError(.monday_opens_at, .init(err, "invalid time"));
                return .failure;
            }
        }

        pub fn tuesday_opens_at(new_place: NewPlaceSelf, repo: *const mantle.Repo, errors: *mantle.validation.RecordErrors(NewPlaceSelf)) !mantle.Repo.CastResult(?Time) {
            _ = repo;

            if (new_place.tuesday_opens_at.len == 0) {
                return .{ .success = null };
            }
            if (Time.parseHtmlTimeInputValue(new_place.tuesday_opens_at)) |time| {
                return .{ .success = time };
            } else |err| {
                try errors.addFieldError(.tuesday_opens_at, .init(err, "invalid time"));
                return .failure;
            }
        }

        pub fn wednesday_opens_at(new_place: NewPlaceSelf, repo: *const mantle.Repo, errors: *mantle.validation.RecordErrors(NewPlaceSelf)) !mantle.Repo.CastResult(?Time) {
            _ = repo;

            if (new_place.wednesday_opens_at.len == 0) {
                return .{ .success = null };
            }
            if (Time.parseHtmlTimeInputValue(new_place.wednesday_opens_at)) |time| {
                return .{ .success = time };
            } else |err| {
                try errors.addFieldError(.wednesday_opens_at, .init(err, "invalid time"));
                return .failure;
            }
        }

        pub fn thursday_opens_at(new_place: NewPlaceSelf, repo: *const mantle.Repo, errors: *mantle.validation.RecordErrors(NewPlaceSelf)) !mantle.Repo.CastResult(?Time) {
            _ = repo;

            if (new_place.thursday_opens_at.len == 0) {
                return .{ .success = null };
            }
            if (Time.parseHtmlTimeInputValue(new_place.thursday_opens_at)) |time| {
                return .{ .success = time };
            } else |err| {
                try errors.addFieldError(.thursday_opens_at, .init(err, "invalid time"));
                return .failure;
            }
        }

        pub fn friday_opens_at(new_place: NewPlaceSelf, repo: *const mantle.Repo, errors: *mantle.validation.RecordErrors(NewPlaceSelf)) !mantle.Repo.CastResult(?Time) {
            _ = repo;

            if (new_place.friday_opens_at.len == 0) {
                return .{ .success = null };
            }
            if (Time.parseHtmlTimeInputValue(new_place.friday_opens_at)) |time| {
                return .{ .success = time };
            } else |err| {
                try errors.addFieldError(.friday_opens_at, .init(err, "invalid time"));
                return .failure;
            }
        }

        pub fn saturday_opens_at(new_place: NewPlaceSelf, repo: *const mantle.Repo, errors: *mantle.validation.RecordErrors(NewPlaceSelf)) !mantle.Repo.CastResult(?Time) {
            _ = repo;

            if (new_place.saturday_opens_at.len == 0) {
                return .{ .success = null };
            }
            if (Time.parseHtmlTimeInputValue(new_place.saturday_opens_at)) |time| {
                return .{ .success = time };
            } else |err| {
                try errors.addFieldError(.saturday_opens_at, .init(err, "invalid time"));
                return .failure;
            }
        }

        pub fn sunday_opens_at(new_place: NewPlaceSelf, repo: *const mantle.Repo, errors: *mantle.validation.RecordErrors(NewPlaceSelf)) !mantle.Repo.CastResult(?Time) {
            _ = repo;

            if (new_place.sunday_opens_at.len == 0) {
                return .{ .success = null };
            }
            if (Time.parseHtmlTimeInputValue(new_place.sunday_opens_at)) |time| {
                return .{ .success = time };
            } else |err| {
                try errors.addFieldError(.sunday_opens_at, .init(err, "invalid time"));
                return .failure;
            }
        }
    };

    pub fn errorsAfterCast(_: *const @This(), errors_after_cast: anytype, errors: *mantle.validation.RecordErrors(@This())) !void {
        for (errors_after_cast.base_errors.items) |base_error_after_cast| {
            try errors.addBaseError(base_error_after_cast);
        }
        var iterator = errors_after_cast.field_errors.iterator();
        while (iterator.next()) |field_errors_entry| {
            if (std.meta.stringToEnum(std.meta.FieldEnum(@This()), @tagName(field_errors_entry.key))) |self_field| {
                for (field_errors_entry.value.items) |field_error| {
                    try errors.addFieldError(self_field, field_error);
                }
            } else {
                for (field_errors_entry.value.items) |field_error| {
                    try errors.addBaseError(field_error);
                }
            }
        }
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
    std.log.info("new place: {f}", .{place});
    switch (try context.repo.create(places, place)) {
        .success => |_| {
            context.helpers.redirectTo("/places");
            return;
        },
        .failure => |errors| {
            context.response.status = 422;
            for (errors.base_errors.items) |base_error| {
                std.log.err("error: {s}", .{base_error.description});
            }
            for (errors.field_errors.values, 0..) |field_errors, field_index| {
                const field = @TypeOf(errors.field_errors).Indexer.keyForIndex(field_index);
                for (field_errors.items) |field_error| {
                    std.log.err("{s} error: {s}", .{ @tagName(field), field_error.description });
                }
            }
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
