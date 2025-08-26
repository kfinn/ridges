const std = @import("std");

const mantle = @import("mantle");
const pg = @import("pg");

const PasswordConfirmation = @import("../models/PasswordConfirmation.zig");
const users = @import("../relations/users.zig");

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

    const repo = mantle.Repo.init(cli.allocator, conn);

    const user = try repo.create(users, .{
        .name = name,
        .email = email,
        .password_bcrypt = password_bcrypt,
    });
    var std_out = std.fs.File.stdout();
    var std_out_buffer: [1024]u8 = undefined;
    var std_out_writer = std_out.writer(&std_out_buffer);
    try std_out_writer.interface.print("Created user {s} with password: {s}\n", .{ user.email, &password_hex });
    try std_out_writer.interface.flush();
}
