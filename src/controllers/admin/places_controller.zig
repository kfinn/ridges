const std = @import("std");

const ezig_templates = @import("ezig_templates");
const httpz = @import("httpz");
const mantle = @import("mantle");
const pg = @import("pg");

const Point = @import("../../models/Point.zig");
const Time = @import("../../models/Time.zig");
const place_tags = @import("../../relations/place_tags.zig");
const places = @import("../../relations/places.zig");
const Context = @import("../../ridges.zig").App.ControllerContext;

pub fn index(context: *Context) !void {
    const admin = try context.helpers.authenticateAdmin(.{}) orelse return;

    const all_places = try context.repo.all(
        places,
        .{},
        .{
            .preloads = &[_]mantle.Repo.Preload{
                .init("place_tags", .{ .preloads = &[_]mantle.Repo.Preload{.init("tag", .{})} }),
            },
        },
    );
    var all_place_urls = try context.response.arena.alloc([]const u8, all_places.len);
    var all_edit_place_urls = try context.response.arena.alloc([]const u8, all_places.len);
    for (all_places, 0..) |place, place_index| {
        all_place_urls[place_index] = try std.fmt.allocPrint(
            context.response.arena,
            "/admin/places/{s}",
            .{try pg.uuidToHex(place.attributes.id)},
        );
        all_edit_place_urls[place_index] = try std.fmt.allocPrint(
            context.response.arena,
            "/admin/places/{s}/edit",
            .{try pg.uuidToHex(place.attributes.id)},
        );
    }

    var response_writer = context.response.writer();
    try ezig_templates.@"layouts/admin_layout.html"(
        &response_writer.interface,
        struct {
            admin: @TypeOf(admin),
            all_places: @TypeOf(all_places),
            all_place_urls: []const []const u8,
            all_edit_place_urls: []const []const u8,

            pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                try ezig_templates.@"admin/places/index.html"(
                    writer,
                    .{
                        .all_places = self.all_places,
                        .all_place_urls = self.all_place_urls,
                        .all_edit_place_urls = self.all_edit_place_urls,
                    },
                );
            }
        }{
            .admin = admin,
            .all_places = all_places,
            .all_place_urls = all_place_urls,
            .all_edit_place_urls = all_edit_place_urls,
        },
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
    tag_ids: []const u8 = "",
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
    price_rating: []const u8 = "3",
    specials_description: []const u8 = "",
    events_description: []const u8 = "",
    bathrooms_description: []const u8 = "",
    food_description: []const u8 = "",
    televisions_count: []const u8 = "",
    size: []const u8 = "",
    is_dog_friendly: []const u8 = "",
    is_queer: []const u8 = "",
    google_url: []const u8 = "",
    instagram_url: []const u8 = "",

    pub fn fromPlace(place: anytype, allocator: std.mem.Allocator) !@This() {
        return .{
            .name = place.attributes.name,
            .location = .{
                .longitude = try std.fmt.allocPrint(allocator, "{d}", .{place.attributes.location.longitude}),
                .latitude = try std.fmt.allocPrint(allocator, "{d}", .{place.attributes.location.latitude}),
            },
            .tag_ids = tag_ids: {
                var buffer: std.Io.Writer.Allocating = .init(allocator);
                var requires_leading_comma = false;
                for (place.associations.place_tags) |place_tag| {
                    if (requires_leading_comma) try buffer.writer.writeByte(',');
                    const uuid_hex = try pg.uuidToHex(place_tag.attributes.tag_id);
                    try buffer.writer.writeAll(&uuid_hex);
                    requires_leading_comma = true;
                }
                try buffer.writer.flush();
                break :tag_ids try buffer.toOwnedSlice();
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
            .price_rating = try std.fmt.allocPrint(allocator, "{d}", .{place.attributes.price_rating}),
            .specials_description = place.attributes.specials_description,
            .events_description = place.attributes.events_description,
            .bathrooms_description = place.attributes.bathrooms_description,
            .food_description = place.attributes.food_description,
            .televisions_count = try std.fmt.allocPrint(allocator, "{d}", .{place.attributes.televisions_count}),
            .size = @tagName(place.attributes.size),
            .is_dog_friendly = if (place.attributes.is_dog_friendly) "1" else "0",
            .is_queer = if (place.attributes.is_queer) "1" else "0",
            .google_url = place.attributes.google_url,
            .instagram_url = place.attributes.instagram_url,
        };
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

    pub const size_options = &[_]mantle.view_helpers.SelectOptions.Option{
        .{ .value = @tagName(places.Size.ten_to_fifteen), .label = "10-15" },
        .{ .value = @tagName(places.Size.fifteen_to_thirty), .label = "15-30" },
        .{ .value = @tagName(places.Size.thirty_plus), .label = "30+" },
    };
};

pub fn new(context: *Context) !void {
    const admin = try context.helpers.authenticateAdmin(.{}) orelse return;

    const change_set: ChangeSet = .{};
    const form = mantle.forms.build(context, change_set, .{});
    const create_tag_csrf_token = context.session.csrf_token.formScoped("/api/tags_multi_select/v1/tags/new", "POST");
    var response_writer = context.response.writer();
    try ezig_templates.@"layouts/admin_layout.html"(
        &response_writer.interface,
        struct {
            admin: @TypeOf(admin),
            form: @TypeOf(form),
            create_tag_csrf_token: @TypeOf(create_tag_csrf_token),

            pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                try ezig_templates.@"admin/places/new.html"(
                    writer,
                    .{
                        .form = self.form,
                        .create_tag_csrf_token = self.create_tag_csrf_token,
                    },
                );
            }
        }{
            .admin = admin,
            .form = form,
            .create_tag_csrf_token = create_tag_csrf_token,
        },
    );
}

pub fn create(context: *Context) !void {
    const admin = try context.helpers.authenticateAdmin(.{}) orelse return;

    const place = try mantle.forms.formDataProtectedFromForgery(context, ChangeSet) orelse return;

    const place_create_result: mantle.Repo.CreateResult(
        places,
        ChangeSet,
        .{ .preloads = &[_]mantle.Repo.Preload{.init("place_tags", .{})} },
    ) = transaction: {
        const transaction = try context.repo.beginTransaction();
        const result = try context.repo.create(places, place, .{ .preloads = &[_]mantle.Repo.Preload{.init("place_tags", .{})} });
        switch (result) {
            .success => |created_place| {
                var tag_ids_iterator = std.mem.splitScalar(u8, place.tag_ids, ',');
                while (tag_ids_iterator.next()) |tag_id| {
                    switch (try context.repo.create(place_tags, .{ .place_id = created_place.attributes.id, .tag_id = tag_id }, .{})) {
                        .failure => {
                            try context.repo.rollbackTransaction(transaction);

                            var errors: mantle.validation.RecordErrors(ChangeSet) = .init(context.response.arena);
                            try errors.addFieldError(.tag_ids, .init(error.InvalidTag, "invalid tag"));
                            break :transaction .{ .failure = errors };
                        },
                        else => {},
                    }
                }
            },
            else => {},
        }
        try context.repo.commitTransaction(transaction);
        break :transaction result;
    };

    switch (place_create_result) {
        .success => {
            context.helpers.redirectTo("/admin/places");
            return;
        },
        .failure => |errors| {
            context.response.status = 422;
            const form = mantle.forms.build(context, place, .{ .errors = errors });
            const create_tag_csrf_token = context.session.csrf_token.formScoped("/api/tags_multi_select/v1/tags/new", "POST");

            var response_writer = context.response.writer();
            try ezig_templates.@"layouts/admin_layout.html"(&response_writer.interface, struct {
                admin: @TypeOf(admin),
                form: @TypeOf(form),
                create_tag_csrf_token: @TypeOf(create_tag_csrf_token),

                pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                    try ezig_templates.@"admin/places/new.html"(
                        writer,
                        .{
                            .form = self.form,
                            .create_tag_csrf_token = self.create_tag_csrf_token,
                        },
                    );
                }
            }{
                .admin = admin,
                .form = form,
                .create_tag_csrf_token = create_tag_csrf_token,
            });
        },
    }
}

pub fn show(context: *Context, params: struct { id: []const u8 }) !void {
    const admin = try context.helpers.authenticateAdmin(.{}) orelse return;

    const place = try context.repo.find(
        places,
        params.id,
        .{
            .preloads = &[_]mantle.Repo.Preload{
                .init("place_tags", .{ .preloads = &[_]mantle.Repo.Preload{.init("tag", .{})} }),
            },
        },
    );

    const edit_place_url = try std.fmt.allocPrint(context.response.arena, "/admin/places/{s}/edit", .{try pg.uuidToHex(place.attributes.id)});
    var response_writer = context.response.writer();
    try ezig_templates.@"layouts/admin_layout.html"(
        &response_writer.interface,
        struct {
            admin: @TypeOf(admin),
            place: @TypeOf(place),
            edit_place_url: []const u8,

            pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                try ezig_templates.@"admin/places/show.html"(
                    writer,
                    .{ .place = self.place, .edit_place_url = self.edit_place_url },
                );
            }
        }{ .admin = admin, .place = place, .edit_place_url = edit_place_url },
    );
}

pub fn edit(context: *Context, params: struct { id: []const u8 }) !void {
    const admin = try context.helpers.authenticateAdmin(.{}) orelse return;

    const place = try context.repo.find(places, params.id, .{ .preloads = &[_]mantle.Repo.Preload{.init("place_tags", .{})} });
    const place_url = try std.fmt.allocPrint(context.response.arena, "/admin/places/{s}", .{try pg.uuidToHex(place.attributes.id)});
    const change_set = try ChangeSet.fromPlace(place, context.response.arena);
    const create_tag_csrf_token = context.session.csrf_token.formScoped("/api/tags_multi_select/v1/tags/new", "POST");
    const form = mantle.forms.build(context, change_set, .{});
    var response_writer = context.response.writer();
    try ezig_templates.@"layouts/admin_layout.html"(
        &response_writer.interface,
        struct {
            admin: @TypeOf(admin),
            place: @TypeOf(place),
            place_url: []const u8,
            form: @TypeOf(form),
            create_tag_csrf_token: @TypeOf(create_tag_csrf_token),

            pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                try ezig_templates.@"admin/places/edit.html"(
                    writer,
                    .{
                        .place = self.place,
                        .place_url = self.place_url,
                        .form = self.form,
                        .create_tag_csrf_token = self.create_tag_csrf_token,
                    },
                );
            }
        }{
            .admin = admin,
            .place = place,
            .place_url = place_url,
            .form = form,
            .create_tag_csrf_token = create_tag_csrf_token,
        },
    );
}

pub fn update(context: *Context, params: struct { id: []const u8 }) !void {
    const admin = try context.helpers.authenticateAdmin(.{}) orelse return;

    const place = try context.repo.find(places, params.id, .{ .preloads = &[_]mantle.Repo.Preload{.{ .name = "place_tags" }} });
    const place_url = try std.fmt.allocPrint(context.response.arena, "/admin/places/{s}", .{try pg.uuidToHex(place.attributes.id)});
    const change_set = try mantle.forms.formDataProtectedFromForgery(context, ChangeSet) orelse return;

    const place_update_result: mantle.Repo.UpdateResult(@TypeOf(place), ChangeSet) = transaction: {
        const transaction = try context.repo.beginTransaction();
        const result = try context.repo.update(place, change_set);
        switch (result) {
            .success => |updated_place| {
                var tag_ids_iterator = std.mem.splitScalar(u8, change_set.tag_ids, ',');
                var visited_tags = try std.DynamicBitSet.initEmpty(context.response.arena, updated_place.associations.place_tags.len);
                defer visited_tags.deinit();

                tags_to_create: while (tag_ids_iterator.next()) |tag_id| {
                    if (tag_id.len == 0) break :tags_to_create;
                    for (updated_place.associations.place_tags, 0..) |existing_place_tag, place_tag_index| {
                        const uuid_hex = try pg.uuidToHex(existing_place_tag.attributes.tag_id);
                        if (std.mem.eql(u8, &uuid_hex, tag_id)) {
                            visited_tags.set(place_tag_index);
                            continue :tags_to_create;
                        }
                    }

                    switch (try context.repo.create(place_tags, .{ .place_id = updated_place.attributes.id, .tag_id = tag_id }, .{})) {
                        .failure => {
                            try context.repo.rollbackTransaction(transaction);

                            var errors: mantle.validation.RecordErrors(ChangeSet) = .init(context.response.arena);
                            try errors.addFieldError(.tag_ids, .init(error.InvalidTag, "invalid tag"));
                            break :transaction .{
                                .failure = .{
                                    .record = updated_place,
                                    .errors = errors,
                                },
                            };
                        },
                        else => {},
                    }
                }

                const tags_to_delete_count = visited_tags.capacity() - visited_tags.count();
                var tag_ids_to_delete = try context.response.arena.alloc([]const u8, tags_to_delete_count);
                defer context.response.arena.free(tag_ids_to_delete);
                var unvisited_tags_iterator = visited_tags.iterator(.{ .kind = .unset });
                var next_tag_id_to_delete_index: usize = 0;
                while (unvisited_tags_iterator.next()) |unvisited_tag_index| {
                    tag_ids_to_delete[next_tag_id_to_delete_index] = place.associations.place_tags[unvisited_tag_index].attributes.tag_id;
                    next_tag_id_to_delete_index += 1;
                }

                switch (try context.repo.deleteAll(place_tags, .{
                    .where = try place_tags.withAnyTagId(&context.repo, tag_ids_to_delete),
                })) {
                    .failure => {
                        try context.repo.rollbackTransaction(transaction);

                        var errors: mantle.validation.RecordErrors(ChangeSet) = .init(context.response.arena);
                        try errors.addFieldError(.tag_ids, .init(error.InvalidTag, "invalid tags"));
                        break :transaction .{
                            .failure = .{
                                .record = updated_place,
                                .errors = errors,
                            },
                        };
                    },
                    else => {},
                }
            },
            else => {},
        }
        try context.repo.commitTransaction(transaction);
        break :transaction result;
    };

    switch (place_update_result) {
        .success => |updated_place| {
            const updated_place_url = try std.fmt.allocPrint(context.response.arena, "/admin/places/{s}", .{try pg.uuidToHex(updated_place.attributes.id)});
            context.helpers.redirectTo(updated_place_url);
            return;
        },
        .failure => |failure| {
            const failed_change_set = try ChangeSet.fromPlace(failure.record, context.response.arena);
            const form = mantle.forms.build(context, failed_change_set, .{ .errors = failure.errors });
            const create_tag_csrf_token = context.session.csrf_token.formScoped("/api/tags_multi_select/v1/tags/new", "POST");
            var response_writer = context.response.writer();
            try ezig_templates.@"layouts/admin_layout.html"(
                &response_writer.interface,
                struct {
                    admin: @TypeOf(admin),
                    place: @TypeOf(place),
                    place_url: []const u8,
                    form: @TypeOf(form),
                    create_tag_csrf_token: @TypeOf(create_tag_csrf_token),
                    pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                        try ezig_templates.@"admin/places/edit.html"(
                            writer,
                            .{
                                .place = self.place,
                                .place_url = self.place_url,
                                .form = self.form,
                                .create_tag_csrf_token = self.create_tag_csrf_token,
                            },
                        );
                    }
                }{
                    .admin = admin,
                    .place = place,
                    .place_url = place_url,
                    .form = form,
                    .create_tag_csrf_token = create_tag_csrf_token,
                },
            );
        },
    }
}
