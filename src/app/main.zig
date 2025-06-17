const std = @import("std");

const httpz = @import("httpz");

const RidgesApp = @import("RidgesApp.zig").RidgesApp;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var app = try RidgesApp.init(allocator, .{ .port = 5882 });
    try app.run();
}
