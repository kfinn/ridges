const std = @import("std");
const pg = @import("pg");

pub const version: i64 = 1755020262855;

pub fn up(app: anytype, conn: *pg.Conn) !void {
    _ = app;
    _ = try conn.exec("CREATE EXTENSION postgis;", .{});
    _ = try conn.exec(
        \\CREATE TABLE places (
        \\  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        \\  name character varying NOT NULL,
        \\  location geography NOT NULL,
        \\  description character varying NOT NULL DEFAULT ''
        \\)
    , .{});
}

pub fn down(app: anytype, conn: *pg.Conn) !void {
    _ = app;
    _ = try conn.exec("DROP TABLE places", .{});
    _ = try conn.exec("DROP EXTENSION postgis", .{});
}
