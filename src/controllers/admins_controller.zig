const Context = @import("../ridges.zig").App.ControllerContext;

pub fn show(context: *Context) !void {
    context.helpers.redirectTo("/admin/places");
}
