const std = @import("std");
const httpz = @import("httpz");
const pg = @import("pg");

const ConnWithDefaultOpts = @import("ConnWithDefaultOpts.zig");

pub fn ControllerContext(comptime App: type) type {
    return struct {
        app: *App,
        db_conn: ConnWithDefaultOpts,
        request: *httpz.Request,
        response: *httpz.Response,

        pub fn init(app: *App, request: *httpz.Request, response: *httpz.Response) !@This() {
            return .{
                .app = app,
                .db_conn = ConnWithDefaultOpts.init(
                    try app.pg_pool.acquire(),
                    .{ .allocator = request.arena },
                ),
                .request = request,
                .response = response,
            };
        }

        pub fn deinit(self: *@This()) void {
            self.db_conn.release();
            self.* = undefined;
        }
    };
}
