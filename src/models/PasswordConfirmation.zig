const std = @import("std");

const mantle = @import("mantle");

password: ?[]const u8 = null,
password_confirmation: ?[]const u8 = null,

pub const Errors = mantle.validation.RecordErrors(@This());

pub fn init(password: ?[]const u8, password_confirmation: ?[]const u8) @This() {
    return .{
        .password = password,
        .password_confirmation = password_confirmation,
    };
}

pub fn fromFormData(form_data: anytype) @This() {
    return .init(
        form_data.get("password"),
        form_data.get("password_confirmation"),
    );
}

pub fn validate(self: *const @This(), errors: *Errors) !void {
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
}

pub fn toPasswordHash(self: *const @This(), allocator: std.mem.Allocator) ![]const u8 {
    var errors = Errors.init(allocator);
    try self.validate(&errors);
    if (errors.isInvalid()) {
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
