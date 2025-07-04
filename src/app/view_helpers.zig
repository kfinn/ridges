const std = @import("std");

pub fn writeLinkTo(writer: std.io.AnyWriter, body: []const u8, url: []const u8) !void {
    try writer.print("<a href=\"{s}\">{s}</a>", .{ url, body });
}
