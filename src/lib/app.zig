const httpz = @import("httpz");
const std = @import("std");

const router_module = @import("router.zig");
const Router = router_module.Router;
const RoutesEntry = router_module.RoutesEntry;
const findRoutesEntriesAction = router_module.findRoutesEntriesAction;
const Params = router_module.Params;

pub const InitOptions = struct { port: u16 };

pub fn App(comptime routes_entries: []const RoutesEntry) type {
    return struct {
        server: httpz.Server(AppRouter),
        app_reference: AppReference = .{},

        const AppSelf = @This();
        pub const AppReference = struct {
            pub const App = AppSelf;
            pub fn app(self: *@This()) *AppSelf {
                return @alignCast(@fieldParentPtr("app_reference", self));
            }
        };
        const AppRouter = Router(AppReference, routes_entries);

        pub fn init(allocator: std.mem.Allocator, initOptions: InitOptions) !@This() {
            const app_reference: AppReference = .{};
            return @This(){ .app_reference = app_reference, .server = try httpz.Server(AppRouter).init(allocator, .{ .port = initOptions.port }, AppRouter{ .app_reference = app_reference }) };
        }

        pub fn run(self: *@This()) !void {
            if (self.server.config.port) |port| {
                std.log.info("Listening on port {d}", .{port});
            }
            try self.server.listen();
        }
    };
}
