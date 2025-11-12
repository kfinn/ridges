// Based on https://libgeos.org/specifications/wkb/

const std = @import("std");

const mantle = @import("mantle");
const pg = @import("pg");

west: f64,
south: f64,
east: f64,
north: f64,

const endian_start_index = 0;
const endian_len = 1;

const type_start_index = endian_start_index + endian_len;
const type_len = 4;

const srid_start_index = type_start_index + type_len;
const srid_len = 4;

const num_rings_start_index = srid_start_index + srid_len;
const num_rings_len = 4;

const num_points_start_index = num_rings_start_index + num_rings_len;
const num_points_len = 4;

const south_west_latitude_start_index = num_points_start_index + num_points_len;
const south_west_latitude_len = 8;

const south_west_longitude_start_index = south_west_latitude_start_index + south_west_latitude_len;
const south_west_longitude_len = 8;

const south_east_latitude_start_index = south_west_longitude_start_index + south_west_longitude_len;
const south_east_latitude_len = 8;

const south_east_longitude_start_index = south_east_latitude_start_index + south_east_latitude_len;
const south_east_longitude_len = 8;

const north_east_latitude_start_index = south_east_longitude_start_index + south_east_longitude_len;
const north_east_latitude_len = 8;

const north_east_longitude_start_index = north_east_latitude_start_index + north_east_latitude_len;
const north_east_longitude_len = 8;

const north_west_latitude_start_index = north_east_longitude_start_index + north_east_longitude_len;
const north_west_latitude_len = 8;

const north_west_longitude_start_index = north_west_latitude_start_index + north_west_latitude_len;
const north_west_longitude_len = 8;

const closing_south_west_latitude_start_index = north_west_longitude_start_index + north_west_longitude_len;
const closing_south_west_latitude_len = 8;

const closing_south_west_longitude_start_index = closing_south_west_latitude_start_index + closing_south_west_latitude_len;
const closing_south_west_longitude_len = 8;

const total_len = closing_south_west_longitude_start_index + closing_south_west_longitude_len;
pub const len = total_len;

const lat_lng_srid = 4326;
const wkb_xdr = 0; // Big Endian
const wkb_ndr = 1; // Little Endian
const wkb_type_polygon_s = 0x20000003; // WWKB 2D polygon with SRID
const num_rings = 1;
const num_points = 5;

pub fn toEwkbPolygon(self: *const @This()) [total_len]u8 {
    var result: [total_len]u8 = undefined;
    result[endian_start_index] = wkb_xdr;
    std.mem.writeInt(u32, result[type_start_index..(type_start_index + type_len)], wkb_type_polygon_s, .big);
    std.mem.writeInt(u32, result[srid_start_index..(srid_start_index + srid_len)], lat_lng_srid, .big);
    std.mem.writeInt(u32, result[num_rings_start_index..(num_rings_start_index + num_rings_len)], num_rings, .big);
    std.mem.writeInt(u32, result[num_points_start_index..(num_points_start_index + num_points_len)], num_points, .big);
    std.mem.writeInt(u64, result[south_west_longitude_start_index..(south_west_longitude_start_index + south_west_longitude_len)], @bitCast(self.west), .big);
    std.mem.writeInt(u64, result[south_west_latitude_start_index..(south_west_latitude_start_index + south_west_latitude_len)], @bitCast(self.south), .big);
    std.mem.writeInt(u64, result[south_east_longitude_start_index..(south_east_longitude_start_index + south_east_longitude_len)], @bitCast(self.east), .big);
    std.mem.writeInt(u64, result[south_east_latitude_start_index..(south_east_latitude_start_index + south_east_latitude_len)], @bitCast(self.south), .big);
    std.mem.writeInt(u64, result[north_east_longitude_start_index..(north_east_longitude_start_index + north_east_longitude_len)], @bitCast(self.east), .big);
    std.mem.writeInt(u64, result[north_east_latitude_start_index..(north_east_latitude_start_index + north_east_latitude_len)], @bitCast(self.north), .big);
    std.mem.writeInt(u64, result[north_west_longitude_start_index..(north_west_longitude_start_index + north_west_longitude_len)], @bitCast(self.west), .big);
    std.mem.writeInt(u64, result[north_west_latitude_start_index..(north_west_latitude_start_index + north_west_latitude_len)], @bitCast(self.north), .big);
    std.mem.writeInt(u64, result[closing_south_west_longitude_start_index..(closing_south_west_longitude_start_index + closing_south_west_longitude_len)], @bitCast(self.west), .big);
    std.mem.writeInt(u64, result[closing_south_west_latitude_start_index..(closing_south_west_latitude_start_index + closing_south_west_latitude_len)], @bitCast(self.south), .big);
    return result;
}

pub fn castToDb(self: *const @This(), repo: *const mantle.Repo) !pg.Binary {
    const result = try repo.allocator.alloc(u8, total_len);
    const ewkb_polygon = self.toEwkbPolygon();
    @memcpy(result, &ewkb_polygon);
    return .{ .data = result };
}
