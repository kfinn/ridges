const std = @import("std");

const httpz = @import("httpz");
const mantle = @import("mantle");

const ridges = @import("ridges.zig");
pub const view_helpers = @import("view_helpers.zig");

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    const allocator = gpa.allocator();

    var env_map = try std.process.getEnvMap(allocator);
    defer env_map.deinit();

    var app = try ridges.init(allocator, &env_map);
    defer app.deinit();

    try mantle.cli.main(allocator, &app);
}
