const std = @import("std");

const httpz = @import("httpz");
const mantle = @import("mantle");

const ridges_app = @import("ridges_app.zig");
pub const view_helpers = @import("view_helpers.zig");

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    const allocator = gpa.allocator();

    var app = try ridges_app.init(allocator);
    defer app.deinit();

    try mantle.cli.main(
        allocator,
        &app,
        .{ .port = 5882, .request = .{ .max_form_count = 1024 } },
    );
}
