const std = @import("std");
const pg = @import("pg");

pub const version: i64 = 1755025663762;

pub fn up(app: anytype, conn: *pg.Conn) !void {
    _ = app;
    _ = try conn.exec(
        \\CREATE TABLE invitations (
        \\  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        \\  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
        \\);
        \\CREATE INDEX index_invitations_on_user_id ON invitations(user_id);
    , .{});
}

pub fn down(app: anytype, conn: *pg.Conn) !void {
    _ = app;
    _ = try conn.exec("DROP TABLE invitations", .{});
}
