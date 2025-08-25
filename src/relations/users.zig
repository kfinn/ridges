const std = @import("std");

const mantle = @import("mantle");

pub const User = struct {
    id: []const u8,
    name: []const u8,
    email: []const u8,
    password_bcrypt: []const u8,
};
pub const Record = User;

pub fn authenticatePassword(user: User, password: []const u8) bool {
    if (std.crypto.pwhash.bcrypt.strVerify(user.password_bcrypt, password, .{ .silently_truncate_password = false })) {
        return true;
    } else |_| {
        return false;
    }
}

pub fn validate(allocator: std.mem.Allocator, record: anytype) !mantle.validation.RecordErrors(@TypeOf(record)) {
    var errors = mantle.validation.RecordErrors(@TypeOf(record)).init(allocator);

    if (record.password_bcrypt.len == 0) {
        try errors.addFieldError(.password_bcrypt, .init(error.Required, "required"));
    }
    if (record.name.len == 0) {
        try errors.addFieldError(.name, .init(error.Required, "required"));
    }
    if (record.email.len == 0) {
        try errors.addFieldError(.email, .init(error.Required, "required"));
    }

    try validateEmail(record, &errors);

    return errors;
}

fn validateEmail(record: anytype, errors: *mantle.validation.RecordErrors(@TypeOf(record))) !void {
    var has_at_sign = false;
    var has_characters_before_at_sign = false;
    var has_characters_after_at_sign = false;

    for (record.email) |c| {
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
