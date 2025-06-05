const httpz = @import("httpz");

pub const Context = @import("./context.zig").Context;

pub fn show(controller_context: *const Context) !void {
    controller_context.response.status = 200;
    controller_context.response.body = "Hello World";
}
