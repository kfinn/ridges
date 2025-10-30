// Based on https://libgeos.org/specifications/wkb/

const std = @import("std");

const mantle = @import("mantle");
const pg = @import("pg");

latitude: f64,
longitude: f64,

const endian_start_index = 0;
const endian_len = 1;

const type_start_index = endian_start_index + endian_len;
const type_len = 4;

const srid_start_index = type_start_index + type_len;
const srid_len = 4;

const latitude_start_index = srid_start_index + srid_len;
const latitude_len = 8;

const longitude_start_index = latitude_start_index + latitude_len;
const longitude_len = 8;

const total_len = longitude_start_index + longitude_len;
pub const len = total_len;

const lat_lng_srid = 4326;

const wkb_xdr = 0; // Big Endian
const wkb_ndr = 1; // Little Endian

const wkb_type_point_s = 0x20000001; // WWKB 2D point with SRID

pub fn fromEwkbPoint(raw_bytes: []const u8) @This() {
    std.debug.assert(raw_bytes.len == total_len);

    const raw_endian = raw_bytes[endian_start_index];
    std.debug.assert(raw_endian == wkb_xdr or raw_endian == wkb_ndr);

    const endian: std.builtin.Endian = if (raw_endian == wkb_xdr) .big else .little;

    const wkb_type = std.mem.readInt(u32, raw_bytes[type_start_index..(type_start_index + type_len)], endian);
    std.debug.assert(wkb_type == wkb_type_point_s);

    const srid = std.mem.readInt(u32, raw_bytes[srid_start_index..(srid_start_index + srid_len)], endian);
    std.debug.assert(srid == lat_lng_srid);

    return .{
        .latitude = @bitCast(std.mem.readInt(
            u64,
            raw_bytes[latitude_start_index..(latitude_start_index + latitude_len)],
            endian,
        )),
        .longitude = @bitCast(std.mem.readInt(
            u64,
            raw_bytes[longitude_start_index..(longitude_start_index + longitude_len)],
            endian,
        )),
    };
}

pub fn toEwkbPoint(self: *const @This()) [total_len]u8 {
    var result: [total_len]u8 = undefined;
    result[endian_start_index] = wkb_xdr;
    std.mem.writeInt(u32, result[type_start_index..(type_start_index + type_len)], wkb_type_point_s, .big);
    std.mem.writeInt(u32, result[srid_start_index..(srid_start_index + srid_len)], lat_lng_srid, .big);
    std.mem.writeInt(u64, result[latitude_start_index..(latitude_start_index + latitude_len)], @bitCast(self.latitude), .big);
    std.mem.writeInt(u64, result[longitude_start_index..(longitude_start_index + longitude_len)], @bitCast(self.longitude), .big);
    return result;
}

pub fn castFromInput(input_point: anytype) !mantle.Repo.CastResult(@This()) {
    comptime {
        const InputPoint = @TypeOf(input_point);
        var has_valid_latitude_field = false;
        var has_valid_longitude_field = false;
        for (std.meta.fields(InputPoint)) |field| {
            if (std.mem.eql(u8, field.name, "longitude")) {
                if (field.type == []const u8) {
                    has_valid_longitude_field = true;
                }
            }
            if (std.mem.eql(u8, field.name, "latitude")) {
                if (field.type == []const u8) {
                    has_valid_latitude_field = true;
                }
            }
        }
        if (!has_valid_latitude_field or !has_valid_longitude_field) {
            @compileError("unable to cast " ++ @typeName(InputPoint) ++ " to Point");
        }
    }

    return .{
        .success = .{
            .latitude = try std.fmt.parseFloat(f64, input_point.latitude),
            .longitude = try std.fmt.parseFloat(f64, input_point.longitude),
        },
    };
}

pub fn castFromDb(db_point: []const u8, _: anytype) !@This() {
    return fromEwkbPoint(db_point);
}

pub fn castToDb(self: *const @This(), repo: *const mantle.Repo) !pg.Binary {
    const result = try repo.allocator.alloc(u8, total_len);
    const ewkb_point = self.toEwkbPoint();
    @memcpy(result, &ewkb_point);
    return .{ .data = result };
}
