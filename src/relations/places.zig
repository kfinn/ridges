const std = @import("std");

const mantle = @import("mantle");
const pg = @import("pg");

const Bounds = @import("../models/Bounds.zig");
const Point = @import("../models/Point.zig");
const Time = @import("../models/Time.zig");

pub const Size = enum { ten_to_fifteen, fifteen_to_thirty, thirty_plus };

pub const Attributes = struct {
    id: []const u8,
    name: []const u8,
    location: Point,
    address: []const u8,
    monday_opens_at: ?Time,
    monday_open_seconds: i32 = 0,
    tuesday_opens_at: ?Time,
    tuesday_open_seconds: i32 = 0,
    wednesday_opens_at: ?Time,
    wednesday_open_seconds: i32 = 0,
    thursday_opens_at: ?Time,
    thursday_open_seconds: i32 = 0,
    friday_opens_at: ?Time,
    friday_open_seconds: i32 = 0,
    saturday_opens_at: ?Time,
    saturday_open_seconds: i32 = 0,
    sunday_opens_at: ?Time,
    sunday_open_seconds: i32 = 0,
    pricing_description: []const u8 = "",
    specials_description: []const u8 = "",
    events_description: []const u8 = "",
    bathrooms_description: []const u8 = "",
    food_description: []const u8 = "",
    televisions_count: i32 = 0,
    size: Size = .ten_to_fifteen,
    is_dog_friendly: bool = false,
    is_queer: bool = false,
    google_url: []const u8 = "",
    instagram_url: []const u8 = "",
};

const end_of_day_microseconds: i64 = 1000000 * 60 * 60 * 24;

pub fn validate(self: anytype, errors: *mantle.validation.RecordErrors(@TypeOf(self))) !void {
    try mantle.validation.validatePresence(self, &.{ .name, .address }, errors);
    try validateDailyHours(self, .monday_opens_at, .monday_open_seconds, .tuesday_opens_at, errors);
    try validateDailyHours(self, .tuesday_opens_at, .tuesday_open_seconds, .wednesday_opens_at, errors);
    try validateDailyHours(self, .wednesday_opens_at, .wednesday_open_seconds, .thursday_opens_at, errors);
    try validateDailyHours(self, .thursday_opens_at, .thursday_open_seconds, .friday_opens_at, errors);
    try validateDailyHours(self, .friday_opens_at, .friday_open_seconds, .saturday_opens_at, errors);
    try validateDailyHours(self, .saturday_opens_at, .saturday_open_seconds, .sunday_opens_at, errors);
    try validateDailyHours(self, .sunday_opens_at, .sunday_open_seconds, .monday_opens_at, errors);
}

fn validateDailyHours(
    self: anytype,
    comptime first_day_opens_at_field: std.meta.FieldEnum(@TypeOf(self)),
    comptime first_day_open_seconds_field: std.meta.FieldEnum(@TypeOf(self)),
    comptime next_day_opens_at_field: std.meta.FieldEnum(@TypeOf(self)),
    errors: *mantle.validation.RecordErrors(@TypeOf(self)),
) !void {
    const first_day_open_seconds = @field(self, @tagName(first_day_open_seconds_field));
    if (@field(self, @tagName(first_day_opens_at_field))) |first_day_opens_at| {
        if (first_day_opens_at.microseconds < 0 or first_day_opens_at.microseconds >= end_of_day_microseconds) {
            try errors.addFieldError(first_day_opens_at_field, .init(error.OutOfRange, "must be a valid time"));
        }
        if (first_day_open_seconds <= 0) {
            try errors.addFieldError(first_day_open_seconds_field, .init(error.OutOfRange, "must be open a positive duration"));
        }
        if (@field(self, @tagName(next_day_opens_at_field))) |next_day_opens_at| {
            if (microsecondsToSeconds(first_day_opens_at.microseconds) + first_day_open_seconds > microsecondsToSeconds(next_day_opens_at.microseconds + end_of_day_microseconds)) {
                try errors.addFieldError(first_day_open_seconds_field, .init(error.OutOfRange, "cannot overlap with the next day's open hours"));
            }
        }
    } else {
        if (first_day_open_seconds != 0) {
            try errors.addFieldError(first_day_open_seconds_field, .init(error.Prohibited, "cannot have a close time without an open time"));
        }
    }
}

fn microsecondsToSeconds(microseconds: i64) i64 {
    return @divTrunc(microseconds, 1000000);
}

pub fn inBounds(repo: *mantle.Repo, bounds: Bounds) !mantle.sql.Where(mantle.sql.ParameterizedSnippet(
    "ST_CoveredBy(location, ?)",
    struct { pg.Binary },
)) {
    return .{ .expression = .{ .params = .{try bounds.castToDb(repo)} } };
}
