const std = @import("std");

const environment_options = @import("environment");
const mantle = @import("mantle");

pub const App = mantle.App(.{
    .router = .{
        .root = .{
            .Controller = @import("controllers/places_maps_controller.zig"),
            .action = "show",
        },
        .routes = &[_]mantle.routing.Route{
            .initNamespace("api", &[_]mantle.routing.Route{
                .initNamespace("map", &[_]mantle.routing.Route{
                    .initNamespace("v1", &[_]mantle.routing.Route{
                        .initResources("places", @import("controllers/api/map/v1/places_controller.zig"), .{}),
                    }),
                }),
                .initNamespace("tags_multi_select", &[_]mantle.routing.Route{
                    .initNamespace("v1", &[_]mantle.routing.Route{
                        .initResources("tags", @import("controllers/api/tags_multi_select/v1/tags_controller.zig"), .{}),
                    }),
                }),
            }),
            .initResource("admin", @import("controllers/admins_controller.zig"), .{ .routes = &[_]mantle.routing.Route{
                .initResource("current_admin", @import("controllers/admin/current_admins_controller.zig"), .{}),
                .initResources("places", @import("controllers/admin/places_controller.zig"), .{}),
                .initResources("sessions", @import("controllers/admin/sessions_controller.zig"), .{}),
                .initResources("tags", @import("controllers/admin/tags_controller.zig"), .{}),
            } }),
            .initResource("map", @import("controllers/maps_controller.zig"), .{ .routes = &[_]mantle.routing.Route{
                .initResource("places", @import("controllers/places_maps_controller.zig"), .{}),
            } }),
        },
        .assets = &[_]type{@import("assets")},
    },
    .Session = struct {
        admin_id: ?[16]u8 = null,
        csrf_token: mantle.CsrfToken = .{},

        pub const key = "Ridges";
    },
    .migrations = &[_]type{
        @import("db/migrations/create_admins.zig"),
        @import("db/migrations/create_places.zig"),
        @import("db/migrations/add_all_simple_attributes_to_places.zig"),
        @import("db/migrations/create_place_tags.zig"),
    },
    .tasks = &[_]type{
        @import("tasks/admins.zig"),
    },
    .controller_helpers = @import("controller_helpers.zig"),
});

pub fn init(allocator: std.mem.Allocator, env_map: *const std.process.EnvMap) !App {
    return try App.init(
        allocator,
        switch (environment_options.environment) {
            .development => @import("environment/development.zig").config,
            .production => try @import("environment/production.zig").buildConfig(allocator, env_map),
        },
    );
}
