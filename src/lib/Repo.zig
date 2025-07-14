const std = @import("std");

const ConnWithDefaultOpts = @import("./ConnWithDefaultOpts.zig");
const inflector = @import("./inflector.zig");
const sql_escape = @import("./sql_escape.zig");

const Options = struct {
    from: ?[]const u8 = null,
};

fn fieldsSqlCount(Record: type) usize {
    var requires_leading_comma = false;
    var fields_sql_count: usize = 0;
    for (std.meta.fieldNames(Record)) |field_name| {
        fields_sql_count += sql_escape.escapedFieldCount(field_name);
        if (requires_leading_comma) {
            fields_sql_count += 2;
        }
        requires_leading_comma = true;
    }
    return fields_sql_count;
}

fn comptimeFieldsSql(Record: type) *const [fieldsSqlCount(Record):0]u8 {
    var requires_leading_comma = false;
    var buf: [fieldsSqlCount(Record):0]u8 = undefined;
    var buf_stream = std.io.fixedBufferStream(&buf);
    var buf_writer = buf_stream.writer();
    requires_leading_comma = false;
    for (std.meta.fieldNames(Record)) |field_name| {
        if (requires_leading_comma) {
            buf_writer.writeAll(", ") catch unreachable;
        }
        sql_escape.writeEscapedField(buf_writer, field_name) catch unreachable;
        requires_leading_comma = true;
    }
    buf[buf.len] = 0;
    const final = buf;
    return &final;
}

fn relativeTypeName(type_name: [:0]const u8) [:0]const u8 {
    var last_dot_index = 0;
    for (type_name, 0..) |c, index| {
        if (c == '.') {
            last_dot_index = index;
        }
    }
    return type_name[last_dot_index + 1 ..];
}

pub fn Repo(comptime Record: type, comptime options: Options) type {
    const from = options.from orelse inflector.comptimeTableize(relativeTypeName(@typeName(Record)));
    const fields_sql = comptimeFieldsSql(Record);

    return struct {
        pub fn find(conn: *ConnWithDefaultOpts, id: i64) !Record {
            const find_sql = std.fmt.comptimePrint("SELECT {s} FROM \"{s}\" WHERE \"id\" = $1", .{ fields_sql, from });

            return (try conn.row(find_sql, .{id})).?.to(Record, .{});
        }

        pub fn all(conn: *ConnWithDefaultOpts) ![]Record {
            const all_sql = std.fmt.comptimePrint("SELECT {s} FROM \"{s}\"", .{ fields_sql, from });

            var all_builder = std.ArrayList(Record).init(conn.default_opts.allocator orelse conn.conn._allocator);
            var rows = try conn.query(all_sql, .{});
            while (try rows.next()) |row| {
                try all_builder.append(try row.to(Record, .{}));
            }
            return try all_builder.toOwnedSlice();
        }
    };
}
