const httpz = @import("httpz");
const std = @import("std");
const pg = @import("pg");

const router_module = @import("Router.zig");
const Router = router_module.Router;
const RoutesEntry = router_module.RoutesEntry;
const findRoutesEntriesAction = router_module.findRoutesEntriesAction;
const Params = router_module.Params;

const controller_context = @import("ControllerContext.zig");

pub const ComptimeOptions = struct {
    router: router_module.ComptimeOptions,
    Session: type = struct {},
};

pub const Config = struct {
    db: pg.Pool.Opts,
    session: struct {
        cookie_secret_key: *const [32]u8,
    },
};

pub fn App(comptime comptime_options: ComptimeOptions) type {
    return struct {
        config: Config,
        router: AppRouter = .{},
        pg_pool: *pg.Pool,

        const AppSelf = @This();
        pub const AppRouter = Router(AppSelf, comptime_options.router);
        pub const ControllerContext = controller_context.ControllerContext(AppSelf);
        pub const Session = comptime_options.Session;

        pub fn init(allocator: std.mem.Allocator, config: Config) !@This() {
            return .{
                .config = config,
                .pg_pool = try pg.Pool.init(allocator, config.db),
            };
        }

        pub fn deinit(self: *@This()) void {
            self.pg_pool.deinit();
            self.* = undefined;
        }
    };
}
