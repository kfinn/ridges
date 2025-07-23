const std = @import("std");

const httpz = @import("httpz");
const ridges_lib = @import("ridges_lib");

const RidgesApp = @import("RidgesApp.zig").RidgesApp;
pub const view_helpers = @import("view_helpers.zig");

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    const allocator = gpa.allocator();

    var app = try RidgesApp.init(
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
    defer app.deinit();

    var server = try httpz.Server(*RidgesApp.AppRouter).init(allocator, .{ .port = 5882, .request = .{ .max_form_count = 10 } }, &app.router);
    defer server.deinit();

    std.log.info("Listening at http://localhost:5882", .{});
    try server.listen();

    std.process.cleanExit();
}
