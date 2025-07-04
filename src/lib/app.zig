const httpz = @import("httpz");
const std = @import("std");
const pg = @import("pg");

const router_module = @import("Router.zig");
const Router = router_module.Router;
const RoutesEntry = router_module.RoutesEntry;
const findRoutesEntriesAction = router_module.findRoutesEntriesAction;
const Params = router_module.Params;

const controller_context = @import("ControllerContext.zig");

pub const InitOptions = struct {
    db: pg.Pool.Opts,
};

pub fn App(comptime routes_entries: []const RoutesEntry) type {
    return struct {
        router: AppRouter = .{},
        pg_pool: *pg.Pool,

        const AppSelf = @This();
        pub const AppRouter = Router(AppSelf, routes_entries);
        pub const ControllerContext = controller_context.ControllerContext(AppSelf);

        pub fn init(allocator: std.mem.Allocator, init_options: InitOptions) !@This() {
            var app: @This() = undefined;
            app.pg_pool = try pg.Pool.init(allocator, init_options.db);

            return app;
        }

        pub fn deinit(self: *@This()) void {
            self.pg_pool.deinit();
            self.* = undefined;
        }
    };
}
