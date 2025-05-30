const httpz = @import("httpz");
const std = @import("std");

const routes_module = @import("routes.zig");
const RoutesEntry = routes_module.RoutesEntry;
const handleRoutesEntries = routes_module.handleRoutesEntries;
const Params = routes_module.Params;

pub const InitOptions = struct { port: u16 };

pub fn App(comptime routes: []const RoutesEntry) type {
    const Handler = struct {
        pub fn handle(_: *@This(), request: *httpz.Request, response: *httpz.Response) void {
            std.debug.assert(request.url.path[0] == '/');
            const handled = handleRoutesEntries(routes, request, response, request.url.path[1..], .none) catch {
                response.status = 500;
                response.body = "Internal Error";
            };
            if (!handled) {
                response.status = 404;
                response.body = "Not Found";
            }
        }
    };

    return struct {
        const Self = @This();
        server: httpz.Server(Handler),

        pub fn init(allocator: std.mem.Allocator, initOptions: InitOptions) !Self {
            return .{ .server = try httpz.Server(Handler).init(allocator, .{ .port = initOptions.port }, .{}) };
        }

        pub fn run(self: *Self) !void {
            if (self.server.config.port) |port| {
                std.log.info("Listening on port {d}", .{port});
            }
            try self.server.listen();
        }
    };
}
