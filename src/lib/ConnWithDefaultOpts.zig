const std = @import("std");
const pg = @import("pg");

conn: *pg.Conn,
default_opts: pg.Conn.QueryOpts = .{},

pub fn init(conn: *pg.Conn, default_opts: pg.Conn.QueryOpts) @This() {
    return .{ .conn = conn, .default_opts = default_opts };
}

pub fn deinit(self: *@This()) void {
    self.conn.deinit();
    self.* = undefined;
}

pub fn release(self: *@This()) void {
    self.conn.release();
}

pub fn query(self: *@This(), sql: []const u8, values: anytype) !*pg.Result {
    return try self.queryOpts(sql, values, null);
}

pub fn queryOpts(self: *@This(), sql: []const u8, values: anytype, opt_opts: ?pg.Conn.QueryOpts) !*pg.Result {
    return try self.conn.queryOpts(
        sql,
        values,
        if (opt_opts) |opts| mergeQueryOpts(opts, self.default_opts) else self.default_opts,
    );
}

pub fn row(self: *@This(), sql: []const u8, values: anytype) !?pg.QueryRow {
    return try self.rowOpts(sql, values, null);
}

pub fn rowOpts(self: *@This(), sql: []const u8, values: anytype, opt_opts: ?pg.Conn.QueryOpts) !?pg.QueryRow {
    return try self.conn.rowOpts(
        sql,
        values,
        if (opt_opts) |opts| mergeQueryOpts(opts, self.default_opts) else self.default_opts,
    );
}

pub fn exec(self: *@This(), sql: []const u8, values: anytype) !?i64 {
    return try self.execOpts(sql, values, null);
}

pub fn execOpts(self: *@This(), sql: []const u8, values: anytype, opt_opts: ?pg.Conn.QueryOpts) !?i64 {
    return try self.conn.execOpts(
        sql,
        values,
        if (opt_opts) |opts| mergeQueryOpts(opts, self.default_opts) else self.default_opts,
    );
}

pub fn begin(self: *@This()) !void {
    try self.conn.begin();
}

pub fn commit(self: *@This()) !void {
    try self.conn.commit();
}

pub fn rollback(self: *@This()) !void {
    try self.conn.rollback();
}

fn mergeQueryOpts(overrides: pg.Conn.QueryOpts, defaults: pg.Conn.QueryOpts) pg.Conn.QueryOpts {
    var result = defaults;

    if (overrides.timeout) |timeout| {
        result.timeout = timeout;
    }
    result.column_names = overrides.column_names;
    if (overrides.allocator) |allocator| {
        result.allocator = allocator;
    }
    result.release_conn = overrides.release_conn;
    if (overrides.cache_name) |cache_name| {
        result.cache_name = cache_name;
    }

    return result;
}
