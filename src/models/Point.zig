// Based on https://libgeos.org/specifications/wkb/

const std = @import("std");

latitude: f64,
longitude: f64,

pub fn fromEwkbPoint(raw_bytes: []const u8) @This() {
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

    std.debug.assert(raw_bytes.len == total_len);

    const wkb_xdr = 0; // Big Endian
    const wkb_ndr = 1; // Little Endian

    const raw_endian = raw_bytes[endian_start_index];
    std.debug.assert(raw_endian == wkb_xdr or raw_endian == wkb_ndr);

    const endian: std.builtin.Endian = if (raw_endian == wkb_xdr) .big else .little;

    const wkb_type_point_s = 0x20000001; // WWKB 2D point with SRID

    const wkb_type = std.mem.readInt(u32, raw_bytes[type_start_index..(type_start_index + type_len)], endian);
    std.debug.assert(wkb_type == wkb_type_point_s);

    const lat_lng_srid = 4326;

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
