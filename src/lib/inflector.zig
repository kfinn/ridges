const std = @import("std");

const SuffixInflection = struct {
    singular_suffix: []const u8,
    plural_suffix: []const u8,
};

const suffix_inflections = [_]SuffixInflection{ .{ .singular_suffix = "y", .plural_suffix = "ies" }, .{ .singular_suffix = "", .plural_suffix = "s" } };

fn findSuffixInflectionFromPlural(plural: []const u8) SuffixInflection {
    for (suffix_inflections) |suffix_inflection| {
        if (std.mem.endsWith(u8, plural, suffix_inflection.plural_suffix)) {
            return suffix_inflection;
        }
    }
    return suffix_inflections[suffix_inflections.len - 1];
}

const IrregularInflection = struct {
    singular: []const u8,
    plural: []const u8,
};

const irregular_inflections = [_]IrregularInflection{ .{ .singular = "person", .plural = "people" }, .{ .singular = "man", .plural = "men" }, .{ .singular = "woman", .plural = "women" }, .{ .singular = "child", .plural = "children" }, .{ .singular = "sex", .plural = "sexes" }, .{ .singular = "move", .plural = "moves" }, .{ .singular = "zombie", .plural = "zombies" }, .{ .singular = "octopus", .plural = "octopuses" } };

fn findIrregularInflectionFromPlural(plural: []const u8) ?IrregularInflection {
    for (irregular_inflections) |irregular_inflection| {
        if (std.mem.eql(u8, plural, irregular_inflection.plural)) {
            return irregular_inflection;
        }
    }
    return null;
}

pub fn singularizeCount(plural: []const u8) usize {
    if (findIrregularInflectionFromPlural(plural)) |irregular_inflection| {
        return irregular_inflection.plural.len;
    }
    const suffix_inflection = findSuffixInflectionFromPlural(plural);
    return plural.len - suffix_inflection.plural_suffix.len + suffix_inflection.singular_suffix.len;
}

pub fn bufSingularize(buf: []u8, plural: []const u8) std.fmt.BufPrintError![]u8 {
    if (findIrregularInflectionFromPlural(plural)) |irregular_inflection| {
        return std.fmt.bufPrint(buf, "{s}", .{irregular_inflection.plural});
    }
    const suffix_inflection = findSuffixInflectionFromPlural(plural);
    return std.fmt.bufPrint(buf, "{s}{s}", .{ plural[0 .. plural.len - suffix_inflection.plural_suffix.len], suffix_inflection.singular_suffix });
}

pub inline fn comptimeSingularize(plural: []const u8) *const [singularizeCount(plural):0]u8 {
    comptime {
        var buf: [singularizeCount(plural):0]u8 = undefined;
        _ = bufSingularize(&buf, plural) catch unreachable;
        buf[buf.len] = 0;
        const final = buf;
        return &final;
    }
}
