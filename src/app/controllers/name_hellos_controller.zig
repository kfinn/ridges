const std = @import("std");

const httpz = @import("httpz");

pub const Context = @import("./context.zig").Context;

pub fn show(controller_context: *const Context, params: struct { name_id: []const u8 }) !void {
    controller_context.response.status = 200;
    try std.fmt.format(controller_context.response.writer(), "hello, {s}", .{params.name_id});
}
