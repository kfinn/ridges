const Context = @import("../ridges_app.zig").RidgesApp.ControllerContext;

pub fn show(context: *Context) !void {
    context.helpers.redirectTo("/map/places");
}
