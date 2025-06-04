const ridges_lib = @import("ridges_lib");
const RoutesEntry = ridges_lib.RoutesEntry;
const Resource = RoutesEntry.Resource;

const HomesController = @import("controllers/homes_controller.zig").HomesController;
const IdsController = @import("controllers/ids_controller.zig").IdsController;

pub const routes = [_]RoutesEntry{ .{ .resource = .{ .name = "home", .Controller = HomesController, .routes = null } }, .{ .resources = .{ .name = "ids", .Controller = IdsController, .routes = null } } };
