const ridges_lib = @import("ridges_lib");

id: i64,
name: []const u8,

pub const Repo = ridges_lib.Repo(@This(), .{});
