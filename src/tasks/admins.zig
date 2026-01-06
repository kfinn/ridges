const std = @import("std");

const mantle = @import("mantle");
const pg = @import("pg");

const admins = @import("../relations/admins.zig");

fn generateRandomPassword() [32]u8 {
    var password_entropy: [16]u8 = undefined;
    std.crypto.random.bytes(&password_entropy);

    var password_hex: [32]u8 = undefined;
    var password_hex_stream = std.io.fixedBufferStream(&password_hex);
    var password_hex_writer = password_hex_stream.writer();
    for (password_entropy) |password_entropy_byte| {
        password_hex_writer.print("{x:0>2}", .{password_entropy_byte}) catch unreachable;
    }
    return password_hex;
}

fn passwordToBcrypt(password: []const u8, allocator: std.mem.Allocator) ![]const u8 {
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

pub fn @"admins:create"(cli: anytype, args: *std.process.ArgIterator) !void {
    const name = args.next() orelse cli.fatal("Usage: admins:create [name] [email]", .{});
    const email = args.next() orelse cli.fatal("Usage: admins:create [name] [email]", .{});

    const password = generateRandomPassword();
    const password_bcrypt = try passwordToBcrypt(&password, cli.allocator);

    const conn: *pg.Conn = try cli.app.pg_pool.acquire();
    defer conn.release();

    const repo = mantle.Repo.init(cli.allocator, conn);

    switch (try repo.create(admins, .{
        .name = name,
        .email = email,
        .password_bcrypt = password_bcrypt,
    })) {
        .success => |admin| {
            var std_out = std.fs.File.stdout();
            var std_out_buffer: [1024]u8 = undefined;
            var std_out_writer = std_out.writer(&std_out_buffer);
            try std_out_writer.interface.print("Created admin {s} with password: {s}\n", .{ admin.attributes.email, &password });
            try std_out_writer.interface.flush();
        },
        .failure => |errors| {
            var std_err = std.fs.File.stderr();
            var std_err_buffer: [1024]u8 = undefined;
            var std_err_writer = std_err.writer(&std_err_buffer);
            try std_err_writer.interface.print("Error: {f}\n", .{errors});
            try std_err_writer.interface.flush();
        },
    }
}

pub fn @"admins:reset_password"(cli: anytype, args: *std.process.ArgIterator) !void {
    const email = args.next() orelse cli.fatal("Usage: admins:reset_password [email]", .{});

    const conn: *pg.Conn = try cli.app.pg_pool.acquire();
    defer conn.release();

    const repo = mantle.Repo.init(cli.allocator, conn);

    const admin = try repo.findBy(admins, .{ .email = email }) orelse cli.fatal("No admin exists with email: {s}", .{email});

    const password = generateRandomPassword();
    const password_bcrypt = try passwordToBcrypt(&password, cli.allocator);

    switch (try repo.update(admins, admin, .{ .password_bcrypt = password_bcrypt })) {
        .success => |updated_admin| {
            var std_out = std.fs.File.stdout();
            var std_out_buffer: [1024]u8 = undefined;
            var std_out_writer = std_out.writer(&std_out_buffer);
            try std_out_writer.interface.print("Updated admin {s} with password: {s}\n", .{ updated_admin.attributes.email, &password });
            try std_out_writer.interface.flush();
        },
        .failure => |failure| {
            var std_err = std.fs.File.stderr();
            var std_err_buffer: [1024]u8 = undefined;
            var std_err_writer = std_err.writer(&std_err_buffer);
            try std_err_writer.interface.print("Error: {f}\n", .{failure.errors});
            try std_err_writer.interface.flush();
        },
    }
}
