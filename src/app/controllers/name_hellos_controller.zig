const ezig_templates = @import("ezig_templates");
const httpz = @import("httpz");

const Context = @import("../RidgesApp.zig").RidgesApp.ControllerContext;

pub fn show(controller_context: *const Context, params: struct { name_id: []const u8 }) !void {
    controller_context.response.status = 200;

    const Props = struct { name_id: []const u8 };
    const props = Props{ .name_id = params.name_id };
    try ezig_templates.@"name_hellos/show.html"(Props, controller_context.response.writer().any(), props);
}
