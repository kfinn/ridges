const ridges_lib = @import("ridges_lib");
const routes = @import("routes.zig").routes;

pub const App = ridges_lib.App(&routes);
