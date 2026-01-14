const std = @import("std");

const ezig_templates = @import("ezig_templates");
const mantle = @import("mantle");

const admins = @import("../../relations/admins.zig");
const Context = @import("../../ridges.zig").App.ControllerContext;

const PasswordChange = struct {
    old_password: []const u8 = "",
    new_password: []const u8 = "",
    new_password_confirmation: []const u8 = "",

    pub fn validate(self: *const @This(), admin: anytype, errors: *mantle.validation.RecordErrors(@This())) !void {
        if (!admin.helpers.verifyPassword(self.old_password)) {
            try errors.addFieldError(.old_password, .init(error.InvalidPassword, "invalid password"));
        }

        if (self.new_password.len == 0) {
            try errors.addFieldError(.new_password, .init(error.Required, "required"));
        }

        if (!std.mem.eql(u8, self.new_password, self.new_password_confirmation)) {
            try errors.addFieldError(.new_password_confirmation, .init(error.InvalidPassword, "must match"));
        }
    }

    const Self = @This();
    pub const casts = struct {
        pub fn password_bcrypt(self: Self, repo: *const mantle.Repo, _: *mantle.validation.RecordErrors(Self)) anyerror![]const u8 {
            return try admins.passwordToBcrypt(self.new_password, repo.allocator);
        }
    };
};

pub fn new(context: *Context) !void {
    const admin = try context.helpers.authenticateAdmin(.{}) orelse return;
    const password_change: PasswordChange = .{};
    const form = mantle.forms.build(context, password_change, .{});
    var response_writer = context.response.writer();
    try ezig_templates.@"layouts/admin_layout.html"(&response_writer.interface, struct {
        admin: @TypeOf(admin),
        form: @TypeOf(form),

        pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
            try ezig_templates.@"admin/password_changes/new.html"(
                writer,
                .{ .admin = self.admin, .form = self.form },
            );
        }
    }{ .admin = admin, .form = form });
}

pub fn create(context: *Context) !void {
    const admin = try context.helpers.authenticateAdmin(.{}) orelse return;
    const password_change = try mantle.forms.formDataProtectedFromForgery(context, PasswordChange) orelse return;

    switch (try context.repo.update(admin, password_change)) {
        .success => {
            context.helpers.redirectTo("/admin/current_admin");
            return;
        },
        .failure => |failure| {
            const form = mantle.forms.build(context, password_change, .{ .errors = failure.errors });
            var response_writer = context.response.writer();
            try ezig_templates.@"layouts/admin_layout.html"(&response_writer.interface, struct {
                admin: @TypeOf(admin),
                form: @TypeOf(form),

                pub fn writeBody(self: *const @This(), writer: *std.Io.Writer) !void {
                    try ezig_templates.@"admin/password_changes/new.html"(
                        writer,
                        .{ .admin = self.admin, .form = self.form },
                    );
                }
            }{ .admin = admin, .form = form });
        },
    }
}
