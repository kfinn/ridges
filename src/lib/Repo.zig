const std = @import("std");

const ConnWithDefaultOpts = @import("./ConnWithDefaultOpts.zig");
const inflector = @import("./inflector.zig");
const sql_escape = @import("./sql_escape.zig");

const Options = struct {
    parent_field_name: ?[]const u8 = null,
    from: ?[]const u8 = null,
};

fn fieldsSqlCount(Record: type, parent_field_name: []const u8) usize {
    var requires_leading_comma = false;
    var fields_sql_count: usize = 0;
    for (@typeInfo(Record).@"struct".fields) |field| {
        if (std.mem.eql(u8, field.name, parent_field_name)) continue;

        fields_sql_count += sql_escape.escapedFieldCount(field.name);
        if (requires_leading_comma) {
            fields_sql_count += 2;
        }
        requires_leading_comma = true;
    }
    return fields_sql_count;
}

fn comptimeFieldsSql(Record: type, parent_field_name: []const u8) *const [fieldsSqlCount(Record, parent_field_name):0]u8 {
    var requires_leading_comma = false;
    var buf: [fieldsSqlCount(Record, parent_field_name):0]u8 = undefined;
    var buf_stream = std.io.fixedBufferStream(&buf);
    var buf_writer = buf_stream.writer();
    requires_leading_comma = false;
    for (@typeInfo(Record).@"struct".fields) |field| {
        if (std.mem.eql(u8, field.name, parent_field_name)) continue;

        if (requires_leading_comma) {
            buf_writer.writeAll(", ") catch unreachable;
        }
        sql_escape.writeEscapedField(buf_writer, field.name) catch unreachable;
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
    const parent_field_name = options.parent_field_name orelse "db";
    const from = options.from orelse inflector.comptimeTableize(relativeTypeName(@typeName(Record)));
    const fields_sql = comptimeFieldsSql(Record, parent_field_name);

    return struct {
        pub fn find(conn: *ConnWithDefaultOpts, id: i64) !Record {
            const find_sql = std.fmt.comptimePrint("SELECT {s} FROM \"{s}\" WHERE \"id\" = $1", .{ fields_sql, from });

            std.debug.print("executing query: {s}, id = {d}\n", .{ find_sql, id });
            return try (try conn.row(find_sql, .{id})).?.to(Record, .{});
        }
    };
}
