const mantle = @import("mantle");

const Context = @import("ridges.zig").App.ControllerContext;
const admins = @import("relations/admins.zig");

fn getContext(self: *@This()) *Context {
    return @alignCast(@fieldParentPtr("helpers", self));
}

pub fn authenticateAdmin(self: *@This()) !?mantle.Repo.relationResultType(admins) {
    var context = self.getContext();

    if (context.session.admin_id) |admin_id| {
        if (context.repo.findBy(admins, .{ .id = admin_id })) |opt_admin| {
            if (opt_admin) |admin| {
                return admin;
            }
        } else |_| {}
    }
    self.redirectTo("/admin/sessions/new");
    return null;
}

pub fn redirectTo(self: *@This(), path: []const u8) void {
    var context = self.getContext();

    context.response.status = 302;
    context.response.header("Location", path);
}
