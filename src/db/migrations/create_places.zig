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
        \\  address character varying NOT NULL,
        \\  monday_opens_at time,
        \\  monday_open_seconds integer NOT NULL DEFAULT 0,
        \\  tuesday_opens_at time,
        \\  tuesday_open_seconds integer NOT NULL DEFAULT 0,
        \\  wednesday_opens_at time,
        \\  wednesday_open_seconds integer NOT NULL DEFAULT 0,
        \\  thursday_opens_at time,
        \\  thursday_open_seconds integer NOT NULL DEFAULT 0,
        \\  friday_opens_at time,
        \\  friday_open_seconds integer NOT NULL DEFAULT 0,
        \\  saturday_opens_at time,
        \\  saturday_open_seconds integer NOT NULL DEFAULT 0,
        \\  sunday_opens_at time,
        \\  sunday_open_seconds integer NOT NULL DEFAULT 0
        \\)
    , .{});
}

pub fn down(app: anytype, conn: *pg.Conn) !void {
    _ = app;
    _ = try conn.exec("DROP TABLE places", .{});
    _ = try conn.exec("DROP EXTENSION postgis", .{});
}
