const ridges_lib = @import("ridges_lib");

id: i64,
name: []const u8,
user_id: i64,
location: []const u8,

db: ridges_lib.Repo(@This(), .{}),
