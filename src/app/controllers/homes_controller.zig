const ezig_templates = @import("ezig_templates");
const httpz = @import("httpz");

pub const Context = @import("./context.zig").Context;

pub fn show(controller_context: *const Context) !void {
    controller_context.response.status = 200;

    const Props = struct {};
    const props = Props{};
    try ezig_templates.@"homes/show.html"(Props, controller_context.response.writer().any(), props);
}
