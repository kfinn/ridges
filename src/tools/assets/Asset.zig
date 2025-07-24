const std = @import("std");

dir: std.fs.Dir,
path: [:0]const u8,

pub fn init(dir: std.fs.Dir, path: [:0]const u8) @This() {
    return .{
        .dir = dir,
        .path = path,
    };
}

pub fn deinit(self: *@This()) void {
    self.* = undefined;
}

pub fn pathWithDigest(self: *const @This(), allocator: std.mem.Allocator) ![]u8 {
    var path_split_iterator = std.mem.splitBackwardsScalar(u8, self.path, '/');
    const filename = path_split_iterator.first();
    const path_prefix = path_split_iterator.rest();

    var filename_split_iterator = std.mem.splitBackwardsScalar(u8, filename, '.');
    const extension = filename_split_iterator.first();
    const filename_prefix = filename_split_iterator.rest();

    if (path_prefix.len > 0) {
        return try std.fmt.allocPrint(
            allocator,
            "{s}/{s}-{s}.{s}",
            .{
                path_prefix,
                filename_prefix,
                try self.digest(),
                extension,
            },
        );
    } else {
        return try std.fmt.allocPrint(
            allocator,
            "{s}-{s}.{s}",
            .{
                filename_prefix,
                try self.digest(),
                extension,
            },
        );
    }
}

fn digest(self: *const @This()) ![std.Build.Cache.Hasher.mac_length * 2]u8 {
    var hasher = std.Build.Cache.hasher_init;

    var file = try self.dir.openFileZ(self.path, .{});
    defer file.close();

    var buffer: [4 * 1024]u8 = undefined;
    while (true) {
        const bytes_read = try file.read(&buffer);
        if (bytes_read == 0) {
            break;
        }
        hasher.update(&buffer);
    }

    const raw_hash = hasher.finalResult();
    var hex_hash: [std.Build.Cache.Hasher.mac_length * 2]u8 = undefined;

    for (raw_hash, 0..) |byte, byte_index| {
        const buf = hex_hash[(2 * byte_index)..(2 * byte_index + 2)];
        _ = std.fmt.bufPrint(buf, "{x}", .{byte}) catch unreachable;
    }

    return hex_hash;
}
