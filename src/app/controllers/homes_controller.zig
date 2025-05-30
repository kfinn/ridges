const httpz = @import("httpz");

pub const HomesController = struct {
    pub fn show(_: *httpz.Request, response: *httpz.Response) !void {
        response.status = 200;
        response.body = "Hello World";
    }
};
