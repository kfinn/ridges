const std = @import("std");

const pg = @import("pg");

pub const version: i64 = 1763141106674;

pub fn up(app: anytype, conn: *pg.Conn) !void {
    _ = app;
    _ = try conn.exec(
        \\CREATE TYPE place_size AS ENUM ('ten_to_fifteen', 'fifteen_to_thirty', 'thirty_plus');
    , .{});
    _ = try conn.exec(
        \\ALTER TABLE places
        \\  ADD COLUMN pricing_description character varying NOT NULL DEFAULT '',
        \\  ADD COLUMN specials_description character varying NOT NULL DEFAULT '',
        \\  ADD COLUMN events_description character varying NOT NULL DEFAULT '',
        \\  ADD COLUMN bathrooms_description character varying NOT NULL DEFAULT '',
        \\  ADD COLUMN food_description character varying NOT NULL DEFAULT '',
        \\  ADD COLUMN televisions_count int NOT NULL DEFAULT 0,
        \\  ADD COLUMN size place_size NOT NULL DEFAULT 'ten_to_fifteen',
        \\  ADD COLUMN is_dog_friendly boolean NOT NULL DEFAULT false,
        \\  ADD COLUMN is_queer boolean NOT NULL DEFAULT false,
        \\  ADD COLUMN google_url character varying NOT NULL DEFAULT '',
        \\  ADD COLUMN instagram_url character varying NOT NULL DEFAULT '';
    , .{});
}

pub fn down(app: anytype, conn: *pg.Conn) !void {
    _ = app;
    _ = try conn.exec(
        \\ALTER TABLE places
        \\  DROP COLUMN pricing_description,
        \\  DROP COLUMN specials_description,
        \\  DROP COLUMN events_description,
        \\  DROP COLUMN bathrooms_description,
        \\  DROP COLUMN food_description,
        \\  DROP COLUMN televisions_count,
        \\  DROP COLUMN size,
        \\  DROP COLUMN is_dog_friendly,
        \\  DROP COLUMN is_queer,
        \\  DROP COLUMN google_url,
        \\  DROP COLUMN instagram_url;
    , .{});

    _ = try conn.exec("DROP TYPE place_size;", .{});
}
