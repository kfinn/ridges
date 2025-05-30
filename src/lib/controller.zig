const httpz = @import("httpz");

const ControllerDefinitionError = error{
    InvalidType,
};

pub fn Controller(comptime App: type, comptime C: type) ControllerDefinitionError!type {
    return struct {
        app: *App,
        request: *httpz.Request,
        response: *httpz.Response,
    };
}
