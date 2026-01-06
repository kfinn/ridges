const std = @import("std");

const pg = @import("pg");

pub const version: i64 = 1754109587203;

pub fn up(app: anytype, conn: *pg.Conn) !void {
    _ = app;
    _ = try conn.exec(
        \\CREATE TABLE admins (
        \\   id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        \\   name character varying NOT NULL,
        \\   email character varying NOT NULL,
        \\   password_bcrypt character varying NOT NULL
        \\)
    , .{});
    _ = try conn.exec(
        \\CREATE UNIQUE INDEX index_admins_on_lower_email ON admins(lower(email));
    , .{});
}

pub fn down(app: anytype, conn: *pg.Conn) !void {
    _ = app;
    _ = try conn.exec(
        \\DROP TABLE admins;
    , .{});
}
