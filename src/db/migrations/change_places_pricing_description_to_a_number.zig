const std = @import("std");

const pg = @import("pg");

pub const version: i64 = 1768583386941;

pub fn up(app: anytype, conn: *pg.Conn) !void {
    _ = app;
    _ = try conn.exec(
        \\ ALTER TABLE places
        \\   DROP COLUMN pricing_description,
        \\   ADD COLUMN price_rating smallint NOT NULL DEFAULT 3 CHECK (price_rating >= 1 AND price_rating <= 5);
    , .{});
    _ = try conn.exec(
        \\ ALTER TABLE places ALTER COLUMN price_rating DROP DEFAULT;
    , .{});
}

pub fn down(app: anytype, conn: *pg.Conn) !void {
    _ = app;
    _ = try conn.exec(
        \\ ALTER TABLE places
        \\   ADD COLUMN pricing_description character varying NOT NULL DEFAULT '',
        \\   DROP COLUMN price_rating;
    , .{});
}
