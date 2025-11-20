const std = @import("std");

const pg = @import("pg");

pub const version: i64 = 1763406755276;

pub fn up(app: anytype, conn: *pg.Conn) !void {
    _ = app;
    _ = try conn.exec(
        \\CREATE TABLE tags (
        \\  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        \\  name character varying NOT NULL
        \\)
    , .{});
    _ = try conn.exec(
        \\CREATE UNIQUE INDEX index_tags_on_lower_name ON tags(lower(name));
    , .{});
    _ = try conn.exec(
        \\CREATE INDEX index_tags_on_name_query ON tags(lower(regexp_replace(name, '\s', '', 'g')))
    , .{});
    _ = try conn.exec(
        \\CREATE TABLE place_tags (
        \\  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        \\  place_id uuid NOT NULL REFERENCES places (id) ON DELETE CASCADE ON UPDATE CASCADE,
        \\  tag_id uuid NOT NULL  REFERENCES tags (id) ON DELETE CASCADE ON UPDATE CASCADE
        \\)
    , .{});
    _ = try conn.exec(
        \\CREATE INDEX index_place_tags_on_place_id ON place_tags(place_id)
    , .{});
    _ = try conn.exec(
        \\CREATE INDEX index_place_tags_on_tag_id ON place_tags(tag_id)
    , .{});
    _ = try conn.exec(
        \\CREATE UNIQUE INDEX uniquely_index_place_tags_on_place_id_and_tag_id ON place_tags(place_id, tag_id)
    , .{});
}

pub fn down(app: anytype, conn: *pg.Conn) !void {
    _ = app;
    _ = try conn.exec("DROP INDEX uniquely_index_place_tags_on_place_id_and_tag_id", .{});
    _ = try conn.exec("DROP INDEX index_place_tags_on_tag_id", .{});
    _ = try conn.exec("DROP INDEX index_place_tags_on_place_id", .{});
    _ = try conn.exec("DROP TABLE place_tags", .{});
    _ = try conn.exec("DROP INDEX index_tags_on_name_query", .{});
    _ = try conn.exec("DROP INDEX index_tags_on_lower_name", .{});
    _ = try conn.exec("DROP TABLE tags", .{});
}
