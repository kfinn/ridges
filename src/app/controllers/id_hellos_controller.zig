const std = @import("std");
const httpz = @import("httpz");
const ridges_lib = @import("ridges_lib");
const App = @import("../app.zig").App;

pub const IdHellosController = struct {
    controller_context: ridges_lib.ControllerContext(App),

    pub fn show(self: *const @This(), params: struct { ids_id: []const u8 }) !void {
        self.controller_context.response.status = 200;
        try std.fmt.format(self.controller_context.response.writer(), "hello, {s}", .{params.ids_id});
    }
};
