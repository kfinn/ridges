const httpz = @import("httpz");
const ridges_lib = @import("ridges_lib");
const App = @import("../app.zig").App;

pub const HomesController = struct {
    controller_context: ridges_lib.ControllerContext(App),

    pub fn show(self: *const @This()) !void {
        self.controller_context.response.status = 200;
        self.controller_context.response.body = "Hello World";
    }
};
