const ezig_templates = @import("ezig_templates");
const httpz = @import("httpz");

const Context = @import("../RidgesApp.zig").RidgesApp.ControllerContext;

pub fn show(context: *const Context, params: struct { id: []const u8 }) !void {
    context.response.status = 200;

    const Props = struct { id: []const u8 };
    const props = Props{ .id = params.id };
    try ezig_templates.@"names/show.html"(Props, context.response.writer().any(), props);
}
