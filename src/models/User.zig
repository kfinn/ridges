const std = @import("std");

const mantle = @import("mantle");

id: i64,
name: []const u8,
email: []const u8,
password_bcrypt: []const u8,

pub fn authenticatePassword(self: *const @This(), password: []const u8) bool {
    if (std.crypto.pwhash.bcrypt.strVerify(self.password_bcrypt, password, .{ .silently_truncate_password = false })) {
        return true;
    } else |_| {
        return false;
    }
}

pub const Repo = mantle.Repo(@This(), .{ .Validator = struct {
    pub fn validate(self: anytype, allocator: std.mem.Allocator) !mantle.validation.RecordErrors(@TypeOf(self)) {
        var errors = mantle.validation.RecordErrors(@TypeOf(self)).init(allocator);

        if (self.password_bcrypt.len == 0) {
            try errors.addFieldError(.password_bcrypt, .init(error.Required, "required"));
        }
        if (self.name.len == 0) {
            try errors.addFieldError(.name, .init(error.Required, "required"));
        }
        if (self.email.len == 0) {
            try errors.addFieldError(.email, .init(error.Required, "required"));
        }

        try validateEmail(self, &errors);

        return errors;
    }

    fn validateEmail(self: anytype, errors: anytype) !void {
        var has_at_sign = false;
        var has_characters_before_at_sign = false;
        var has_characters_after_at_sign = false;

        for (self.email) |c| {
            switch (c) {
                '@' => {
                    if (has_at_sign) {
                        try errors.addFieldError(.email, .init(error.InvalidEmailFormat, "must be a valid email address (too many @ signs)"));
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
                    try errors.addFieldError(.email, .init(error.InvalidEmailFormat, try std.fmt.allocPrintZ(errors.allocator, "must be a valid email address (contains {c})", .{c})));
                    return;
                },
            }
        }

        if (!has_at_sign or !has_characters_before_at_sign or !has_characters_after_at_sign) {
            try errors.addFieldError(.email, .init(error.InvalidEmailFormat, "must be a valid email address (missing required section)"));
        }
    }
} });
