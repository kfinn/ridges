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

// unused below this line

fn findSuffixnflectionFromSingular(singular: []const u8) SuffixInflection {
    for (suffix_inflections) |suffix_inflection| {
        if (std.mem.endsWith(u8, singular, suffix_inflection.singular_suffix)) {
            return suffix_inflection;
        }
    }
    return suffix_inflections[suffix_inflections.len - 1];
}

fn findIrregularInflectionFromSingular(singular: []const u8) ?IrregularInflection {
    for (irregular_inflections) |irregular_inflection| {
        if (std.mem.eql(u8, singular, irregular_inflection.singular)) {
            return irregular_inflection;
        }
    }
    return null;
}

pub fn pluralizeCount(singular: []const u8) usize {
    if (findIrregularInflectionFromSingular(singular)) |irregular_inflection| {
        return irregular_inflection.plural.len;
    }
    const suffix_inflection = findSuffixnflectionFromSingular(singular);
    return singular.len - suffix_inflection.singular_suffix.len + suffix_inflection.plural_suffix.len;
}

pub fn bufPluralize(buf: []u8, singular: []const u8) std.fmt.BufPrintError![]u8 {
    if (findIrregularInflectionFromSingular(singular)) |irregular_inflection| {
        return std.fmt.bufPrint(buf, "{s}", .{irregular_inflection.plural});
    }
    const suffix_inflection = findSuffixnflectionFromSingular(singular);
    return std.fmt.bufPrint(buf, "{s}{s}", .{ singular[0 .. singular.len - suffix_inflection.singular_suffix.len], suffix_inflection.plural_suffix });
}

pub inline fn comptimePluralize(singular: []const u8) *const [pluralizeCount(singular):0]u8 {
    comptime {
        var buf: [pluralizeCount(singular):0]u8 = undefined;
        _ = bufPluralize(&buf, singular) catch unreachable;
        buf[buf.len] = 0;
        const final = buf;
        return &final;
    }
}

const word_delimiters = [_]u8{ ' ', '-', '_' };

pub fn camelizeCount(text: []const u8) usize {
    var characters_to_delete: usize = 0;
    for (text) |character| {
        if (std.mem.containsAtLeastScalar(u8, word_delimiters, 1, character)) characters_to_delete += 1;
    }
    return text.len - characters_to_delete;
}

pub fn bufCamelize(buf: []u8, text: []const u8) std.fmt.BufPrintError![]u8 {
    var splitIterator = std.mem.splitAny(u8, text, word_delimiters);
    var writer = std.io.fixedBufferStream(buf).writer();
    while (splitIterator.next()) |word| {
        const first = word[0];
        writer.writeByte(switch (first) {
            'a'...'z' => |lowercase_letter| lowercase_letter - 'a' + 'A',
            else => |other_character| other_character,
        });
        writer.write(word[1..]);
    }
    return buf;
}

pub inline fn comptimeCamelize(text: []const u8) *const [camelizeCount(text):0]u8 {
    comptime {
        var buf: [camelizeCount(text):0]u8 = undefined;
        _ = bufCamelize(&buf, text);
        buf[buf.len] = 0;
        const final = buf;
        return &final;
    }
}
