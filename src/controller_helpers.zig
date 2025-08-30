const mantle = @import("mantle");

const Context = @import("ridges_app.zig").RidgesApp.ControllerContext;
const users = @import("relations/users.zig");

fn getContext(self: *@This()) *Context {
    return @alignCast(@fieldParentPtr("helpers", self));
}

pub fn authenticateUser(self: *@This()) !?mantle.Repo.relationResultType(users) {
    var context = self.getContext();

    if (context.session) |session| {
        if (context.repo.findBy(users, .{ .id = session.user_id })) |opt_user| {
            if (opt_user) |user| {
                return user;
            }
        } else |_| {}
    }
    self.redirectTo("/sessions/new");
    return null;
}

pub fn redirectTo(self: *@This(), path: []const u8) void {
    var context = self.getContext();

    context.response.status = 302;
    context.response.header("Location", path);
}
