const std = @import("std");

const mantle = @import("mantle");
const Route = mantle.Route;
const Resource = Route.Resource;

pub const RidgesApp = mantle.App(.{
    .router = .{
        .root = .{
            .Controller = @import("controllers/places_controller.zig"),
            .action = "index",
        },
        .routes = &[_]Route{
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
        user_id: [16]u8,
        csrf_token: ?[32]u8 = null,

        pub const key = "RidgesApp";
    },
    .migrations = &[_]type{
        @import("db/migrations/create_users.zig"),
        @import("db/migrations/create_places.zig"),
        @import("db/migrations/create_invitations.zig"),
    },
    .tasks = &[_]type{
        @import("tasks/users.zig"),
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
