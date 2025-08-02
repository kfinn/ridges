const std = @import("std");
const pg = @import("pg");

pub const version: i64 = 1754109587203;

pub fn up(app: anytype, conn: *pg.Conn) !void {
    _ = app;
    _ = try conn.exec(
        \\CREATE TABLE users (
        \\   id BIGSERIAL PRIMARY KEY,
        \\   name character varying NOT NULL,
        \\   email character varying NOT NULL,
        \\   password_bcrypt character varying NOT NULL
        \\)
    , .{});
    _ = try conn.exec(
        \\CREATE INDEX index_users_on_email ON users(email text_ops);
    , .{});
}

pub fn down(app: anytype, conn: *pg.Conn) !void {
    _ = app;
    _ = try conn.exec(
        \\DROP TABLE users;
    , .{});
}
