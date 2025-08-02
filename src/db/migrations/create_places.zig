const std = @import("std");
const pg = @import("pg");

pub const version: i64 = 1754113035286;

pub fn up(app: anytype, conn: *pg.Conn) !void {
    _ = app;
    _ = try conn.exec(
        \\CREATE TABLE places (
        \\    id BIGSERIAL PRIMARY KEY,
        \\    name character varying NOT NULL,
        \\    location geography(Point,4326) NOT NULL,
        \\    user_id BIGSERIAL REFERENCES users(id)
        \\);
        \\CREATE INDEX index_places_on_user_id ON places(user_id int8_ops);
    ,
        .{},
    );
}

pub fn down(app: anytype, conn: *pg.Conn) !void {
    _ = app;
    _ = try conn.exec("DROP TABLE places", .{});
}
