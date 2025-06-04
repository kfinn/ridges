const ridges_lib = @import("ridges_lib");
const RoutesEntry = ridges_lib.RoutesEntry;
const Resource = RoutesEntry.Resource;

const HomesController = @import("controllers/homes_controller.zig").HomesController;
const IdsController = @import("controllers/ids_controller.zig").IdsController;
const IdHellosController = @import("controllers/id_hellos_controller.zig").IdHellosController;

pub const routes = [_]RoutesEntry{ .{ .resource = .{ .name = "home", .Controller = HomesController, .routes = null } }, .{ .resources = .{ .name = "ids", .Controller = IdsController, .routes = &[_]RoutesEntry{.{ .resource = .{ .name = "hello", .Controller = IdHellosController, .routes = null } }} } } };
