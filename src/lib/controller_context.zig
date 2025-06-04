const httpz = @import("httpz");

pub fn ControllerContext(comptime App: type) type {
    return struct {
        app: *App,
        request: *httpz.Request,
        response: *httpz.Response,
    };
}
