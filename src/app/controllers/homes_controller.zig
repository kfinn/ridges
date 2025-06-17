const ezig_templates = @import("ezig_templates");
const httpz = @import("httpz");

const Context = @import("../RidgesApp.zig").RidgesApp.ControllerContext;

pub fn show(controller_context: *const Context) !void {
    controller_context.response.status = 200;

    const Props = struct {};
    const props = Props{};
    try ezig_templates.@"homes/show.html"(Props, controller_context.response.writer().any(), props);
}
