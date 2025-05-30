const std = @import("std");
const httpz = @import("httpz");
const lib = @import("ridges_lib");
const routes = @import("routes.zig").routes;

const App = lib.App(&routes);

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var app = try App.init(allocator, .{ .port = 5882 });
    try app.run();
}
