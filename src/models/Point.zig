// Based on https://libgeos.org/specifications/wkb/

const std = @import("std");

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
    std.log.info("ewkb: {any}", .{raw_bytes});
    std.log.info("ewkb: {x}", .{raw_bytes});

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

pub fn writeStringEncodedGeography(self: *const @This(), writer: *std.Io.Writer) !void {
    try writer.print("SRID=4326;POINT({d} {d})", .{ self.longitude, self.latitude });
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
