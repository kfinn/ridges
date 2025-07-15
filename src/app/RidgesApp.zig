const ridges_lib = @import("ridges_lib");
const RoutesEntry = ridges_lib.RoutesEntry;
const Resource = RoutesEntry.Resource;

pub const RidgesApp = ridges_lib.App(.{
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
        .{ .resources = .{
            .name = "places",
            .Controller = @import("controllers/places_controller.zig"),
        } },
    },
    .Session = struct {
        num: i32,

        pub const key = "RidgesApp";
    },
});
