const std = @import("std");

const ridges_lib = @import("ridges_lib");

password: ?[]const u8 = null,
password_confirmation: ?[]const u8 = null,

pub const Errors = ridges_lib.validation.RecordErrors(@This());

pub fn fromFormData(form_data: anytype) @This() {
    return .{
        .password = form_data.get("password"),
        .password_confirmation = form_data.get("password_confirmation"),
    };
}

pub fn validate(self: *const @This(), allocator: std.mem.Allocator) !Errors {
    var errors = Errors.init(allocator);

    if (self.password == null) {
        try errors.addFieldError(.password, .init(error.Required, "required"));
    }
    if (self.password_confirmation == null) {
        try errors.addFieldError(.password_confirmation, .init(error.Required, "required"));
    }

    if (self.password) |password| {
        if (password.len < 8) {
            try errors.addFieldError(.password, .init(error.TooShort, "must be at least 8 characters"));
        }
        if (password.len > 72) {
            try errors.addFieldError(.password, .init(error.TooLong, "must be fewer than 72 characters"));
        }
        if (self.password_confirmation) |password_confirmation| {
            if (!std.mem.eql(u8, password, password_confirmation)) {
                try errors.addBaseError(.init(error.Mismatched, "password and confirmation must match"));
            }
        }
    }

    return errors;
}

pub fn toPasswordHash(self: *const @This(), allocator: std.mem.Allocator) ![]const u8 {
    if ((try self.validate(allocator)).isInvalid()) {
        return error.RecordInvalid;
    }

    var buf: [std.crypto.pwhash.bcrypt.hash_length * 2]u8 = undefined;
    const password_hash = try std.crypto.pwhash.bcrypt.strHash(self.password.?, .{
        .encoding = .phc,
        .allocator = allocator,
        .params = .owasp,
    }, &buf);

    const final = try allocator.alloc(u8, password_hash.len);
    @memcpy(final, password_hash);
    return final;
}
