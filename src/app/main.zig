const std = @import("std");
const httpz = @import("httpz");
const routes = @import("routes.zig").routes;
const App = @import("app.zig").App;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var app = try App.init(allocator, .{ .port = 5882 });
    try app.run();
}
