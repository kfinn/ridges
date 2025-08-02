const std = @import("std");

const mantle = @import("mantle");
const RoutesEntry = mantle.RoutesEntry;
const Resource = RoutesEntry.Resource;

pub const RidgesApp = mantle.App(.{
    .router = .{
        .routes_entries = &[_]RoutesEntry{
            .{ .resource = .{
                .name = "home",
                .Controller = @import("controllers/homes_controller.zig"),
            } },
            .{ .resources = .{
                .name = "names",
                .Controller = @import("controllers/names_controller.zig"),
                .routes = &[_]RoutesEntry{.{
                    .resource = .{
                        .name = "hello",
                        .Controller = @import("controllers/name_hellos_controller.zig"),
                    },
                }},
            } },
            .{ .resources = .{
                .name = "users",
                .Controller = @import("controllers/users_controller.zig"),
            } },
            .{ .resource = .{
                .name = "current_user",
                .Controller = @import("controllers/current_users_controller.zig"),
            } },
            .{ .resources = .{
                .name = "places",
                .Controller = @import("controllers/places_controller.zig"),
            } },
            .{ .resources = .{
                .name = "sessions",
                .Controller = @import("controllers/sessions_controller.zig"),
            } },
        },
        .assets = &[_]type{@import("assets")},
    },
    .Session = struct {
        user_id: i64,

        pub const key = "RidgesApp";
    },
    .migrations = &[_]type{
        @import("db/migrations/create_users.zig"),
        @import("db/migrations/create_places.zig"),
    },
});

pub fn init(allocator: std.mem.Allocator) !RidgesApp {
    return try RidgesApp.init(
        allocator,
        .{
            .db = .{
                .auth = .{
                    .username = "ridges",
                    .password = "password",
                    .database = "ridges",
                    .application_name = "Ridges",
                },
            },
            .session = .{
                .cookie_secret_key = "de86040470140bcaa6cf34b4dc34edf3",
            },
        },
    );
}
