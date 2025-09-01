const std = @import("std");

const ezig_templates = @import("ezig_templates");
const httpz = @import("httpz");
const mantle = @import("mantle");

const Point = @import("../models/Point.zig");
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
    description: []const u8 = "",
    location: struct {
        longitude: []const u8 = "-73.9029527",
        latitude: []const u8 = "40.7014435",
    } = .{},

    pub const cast_fields: []const std.meta.FieldEnum(places.Attributes) = &[_]std.meta.FieldEnum(places.Attributes){.location};

    pub fn castField(self: *const @This(), comptime field: std.meta.FieldEnum(places.Attributes), repo: *const mantle.Repo, errors: *mantle.validation.RecordErrors((@This()))) !mantle.Repo.CastResult(places, field) {
        std.debug.assert(field == .location);

        var point: Point = undefined;
        point.latitude = std.fmt.parseFloat(f64, self.location.latitude) catch |err| {
            try errors.addFieldError(.location, .init(err, "invalid"));
            return .{ .failure = {} };
        };
        point.longitude = std.fmt.parseFloat(f64, self.location.longitude) catch |err| {
            try errors.addFieldError(.location, .init(err, "invalid"));
            return .{ .failure = {} };
        };

        var location_writer: std.Io.Writer.Allocating = .init(repo.allocator);
        try point.writeStringEncodedGeography(&location_writer.writer);
        return .{ .success = try location_writer.toOwnedSlice() };
    }

    pub fn errorsAfterCast(_: *const @This(), errors_after_cast: anytype, errors: *mantle.validation.RecordErrors(@This())) !void {
        for (errors_after_cast.base_errors.items) |base_error_after_cast| {
            try errors.addBaseError(base_error_after_cast);
        }
        var iterator = errors_after_cast.field_errors.iterator();
        while (iterator.next()) |field_errors_entry| {
            const self_field: std.meta.FieldEnum(@This()) = switch (field_errors_entry.key) {
                .name => .name,
                .description => .description,
                .location => .location,
            };
            for (field_errors_entry.value.items) |field_error| {
                try errors.addFieldError(self_field, field_error);
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
    switch (context.repo.create(places, place) catch |err| {
        if (context.repo.conn.err) |pg_err| {
            std.log.info("pg stuff {s}", .{pg_err.message});
        }
        return err;
    }) {
        .success => |_| {
            context.helpers.redirectTo("/places");
            return;
        },
        .failure => |errors| {
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
