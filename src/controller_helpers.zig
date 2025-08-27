const Context = @import("ridges_app.zig").RidgesApp.ControllerContext;
const users = @import("relations/users.zig");

fn getContext(self: *@This()) *Context {
    return @alignCast(@fieldParentPtr("helpers", self));
}

pub fn authenticateUser(self: *@This()) !?users.User {
    var context = self.getContext();

    if (context.session) |session| {
        if (try context.repo.findBy(users, .{ .id = session.user_id })) |user| {
            return user;
        }
    }
    redirectTo(context, "/sessions/new");
    return null;
}

pub fn redirectTo(self: *@This(), path: []const u8) void {
    var context = self.getContext();

    context.response.status = 302;
    context.response.header("Location", path);
}
