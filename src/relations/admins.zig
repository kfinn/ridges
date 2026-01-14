const std = @import("std");

const mantle = @import("mantle");

const admins = @This();

pub const Attributes = struct {
    id: []const u8,
    name: []const u8,
    email: []const u8,
    password_bcrypt: []const u8,
};

pub const NewSession = struct {
    email: []const u8 = "",
    password: []const u8 = "",
};

const AuthenticateResult = union(enum) {
    success: mantle.Repo.relationResultTypeWithOpts(admins, .{}),
    failure: mantle.validation.RecordErrors(NewSession),
};

pub fn authenticate(allocator: std.mem.Allocator, repo: *mantle.Repo, new_session: NewSession) !AuthenticateResult {
    var errors: mantle.validation.RecordErrors(NewSession) = .init(allocator);

    if (new_session.email.len == 0) {
        try errors.addFieldError(.email, .init(error.Required, "required"));
    }
    if (new_session.password.len == 0) {
        try errors.addFieldError(.password, .init(error.Required, "required"));
    }
    if (errors.isInvalid()) return .{ .failure = errors };

    const admin = try repo.findBy(@This(), .{ .email = new_session.email }, .{}) orelse {
        try errors.addFieldError(.email, .init(error.NotFound, "not found"));
        return .{ .failure = errors };
    };

    if (admin.helpers.verifyPassword(new_session.password)) {
        return .{ .success = admin };
    } else {
        try errors.addFieldError(.password, .init(error.InvalidPassword, "invalid"));
        return .{ .failure = errors };
    }
}

pub fn Helpers(comptime Admin: type, comptime field_name: []const u8) type {
    return struct {
        pub fn getAdmin(self: *const @This()) *const Admin {
            return @alignCast(@fieldParentPtr(field_name, self));
        }

        pub fn verifyPassword(self: *const @This(), password: []const u8) bool {
            if (std.crypto.pwhash.bcrypt.strVerify(
                self.getAdmin().attributes.password_bcrypt,
                password,
                .{
                    .silently_truncate_password = false,
                },
            )) {
                return true;
            } else |_| {
                return false;
            }
        }
    };
}

pub fn validate(self: anytype, errors: *mantle.validation.RecordErrors(@TypeOf(self))) !void {
    if (self.password_bcrypt.len == 0) {
        try errors.addFieldError(.password_bcrypt, .init(error.Required, "required"));
    }
    if (self.name.len == 0) {
        try errors.addFieldError(.name, .init(error.Required, "required"));
    }
    if (self.email.len == 0) {
        try errors.addFieldError(.email, .init(error.Required, "required"));
    }

    try validateEmail(self, errors);
}

fn validateEmail(self: anytype, errors: *mantle.validation.RecordErrors(@TypeOf(self))) !void {
    var has_at_sign = false;
    var has_characters_before_at_sign = false;
    var has_characters_after_at_sign = false;

    for (self.email) |c| {
        switch (c) {
            '@' => {
                if (has_at_sign) {
                    try errors.addFieldError(.email, .init(error.InvalidEmailFormat, "must be a valid email address"));
                    return;
                }
                has_at_sign = true;
            },
            'a'...'z', 'A'...'Z', '0'...'9', '!', '#', '$', '%', '&', '\'', '*', '+', '-', '/', '=', '?', '^', '_', '`', '{', '|', '}', '~', '.' => {
                if (has_at_sign) {
                    has_characters_after_at_sign = true;
                } else {
                    has_characters_before_at_sign = true;
                }
            },
            else => {
                try errors.addFieldError(.email, .init(error.InvalidEmailFormat, try std.fmt.allocPrintSentinel(
                    errors.allocator,
                    "must be a valid email address (contains invalid character '{c}')",
                    .{c},
                    0,
                )));
                return;
            },
        }
    }

    if (!has_at_sign or !has_characters_before_at_sign or !has_characters_after_at_sign) {
        try errors.addFieldError(.email, .init(error.InvalidEmailFormat, "must be a valid email address"));
    }
}

pub fn passwordToBcrypt(password: []const u8, allocator: std.mem.Allocator) ![]const u8 {
    var buf: [std.crypto.pwhash.bcrypt.hash_length * 2]u8 = undefined;
    const password_hash = try std.crypto.pwhash.bcrypt.strHash(password, .{
        .encoding = .phc,
        .allocator = allocator,
        .params = .owasp,
    }, &buf);

    const final = try allocator.alloc(u8, password_hash.len);
    @memcpy(final, password_hash);
    return final;
}
