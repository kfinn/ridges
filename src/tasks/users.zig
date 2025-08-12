const std = @import("std");
const pg = @import("pg");

const PasswordConfirmation = @import("../models/PasswordConfirmation.zig");
const User = @import("../models/User.zig");

pub fn @"users:create"(cli: anytype, args: *std.process.ArgIterator) !void {
    const name = args.next() orelse cli.fatal("Usage: users:create [name] [email]", .{});
    const email = args.next() orelse cli.fatal("Usage: users:create [name] [email]", .{});

    var password_entropy: [16]u8 = undefined;
    std.crypto.random.bytes(&password_entropy);

    var password_hex: [32]u8 = undefined;
    var password_hex_stream = std.io.fixedBufferStream(&password_hex);
    var password_hex_writer = password_hex_stream.writer();
    for (password_entropy) |password_entropy_byte| {
        password_hex_writer.print("{x:0>2}", .{password_entropy_byte}) catch unreachable;
    }

    const password_confirmation = PasswordConfirmation.init(&password_hex, &password_hex);
    const password_bcrypt = try password_confirmation.toPasswordHash(cli.allocator);

    const conn: *pg.Conn = try cli.app.pg_pool.acquire();
    defer conn.release();

    const user = try User.Repo.create(conn, cli.allocator, .{
        .name = name,
        .email = email,
        .password_bcrypt = password_bcrypt,
    });
    var std_out_writer = std.io.getStdOut().writer();
    try std_out_writer.print("Created user {s} with password: {s}\n", .{ user.email, &password_hex });
}
