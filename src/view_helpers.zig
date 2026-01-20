const std = @import("std");

const assets = @import("assets");
const environment_options = @import("environment");
const mantle = @import("mantle");
pub const mantle_view_helpers = mantle.view_helpers;
const pg = @import("pg");

const ridges = @import("ridges.zig");

pub const LinkOptions = struct { class: ?[]const u8 = null };
pub const link_options: LinkOptions = .{ .class = "text-purple-600 dark:text-purple-500 hover:underline" };

pub fn writeLinkTo(writer: *std.Io.Writer, body: []const u8, url: []const u8, options: LinkOptions) !void {
    var merged_options: LinkOptions = link_options;
    if (options.class) |class| {
        merged_options.class = class;
    }

    try mantle_view_helpers.writeHtmlTag(
        writer,
        "a",
        .{
            .class = merged_options.class,
            .href = url,
        },
        .{},
    );
    try mantle.cgi_escape.writeEscapedHtml(writer, body);
    try writer.writeAll("</a>");
}

pub const errors_options: mantle_view_helpers.ErrorsOptions = .{ .class = "text-red-600 dark:text-red-500" };

pub fn writeFieldErrors(writer: *std.Io.Writer, errors: anytype, field: @TypeOf(errors).Field) !void {
    try mantle_view_helpers.writeFieldErrors(writer, errors, field, errors_options);
}

pub fn writeErrors(writer: *std.Io.Writer, errors: []mantle.validation.Error) !void {
    try mantle_view_helpers.writeErrors(writer, errors, errors_options);
}

pub fn writeH2(writer: *std.Io.Writer, body: []const u8) !void {
    try beginH2(writer);
    try mantle.cgi_escape.writeEscapedHtml(writer, body);
    try endH2(writer);
}

pub fn beginH2(writer: *std.Io.Writer) !void {
    try mantle_view_helpers.writeHtmlTag(writer, "h2", .{ .class = "text-lg " }, .{});
}

pub fn endH2(writer: *std.Io.Writer) !void {
    try writer.writeAll("</h2>");
}

pub fn beginUl(writer: *std.Io.Writer) !void {
    try mantle_view_helpers.writeHtmlTag(writer, "ul", .{ .class = "list-disc " }, .{});
}

pub fn endUl(writer: *std.Io.Writer) !void {
    try writer.writeAll("</ul>");
}

pub const form_class = "flex flex-col items-stretch space-y-2";

pub fn beginForm(writer: *std.Io.Writer, form: anytype) !void {
    try form.beginForm(writer, .{ .class = form_class });
}

pub fn endForm(writer: *std.Io.Writer, form: anytype) !void {
    try form.endForm(writer);
}

pub const field_options: mantle_view_helpers.FieldOptions = .{
    .label = .{ .class = field_label_class },
    .input = .{ .text = .{ .class = field_input_class } },
    .errors = errors_options,
};
const field_label_class: []const u8 = "flex flex-col items-stretch space-y-1";
const checkbox_field_label_class: []const u8 = "flex justify-start items-center space-x-1";
const field_input_class: []const u8 = "rounded outline-1 focus:outline-2 outline-gray-300 dark:outline-gray-600 dark:scheme-dark";

fn applyInputDefaults(input_options: anytype) void {
    if (input_options.class == null) input_options.class = field_input_class;
}

pub fn writeFormField(
    writer: *std.Io.Writer,
    form: anytype,
    comptime name: anytype,
    options: mantle_view_helpers.FieldOptions,
) !void {
    var options_with_defaults = options;
    if (options_with_defaults.label.class == null) options_with_defaults.label.class = field_label_class;

    switch (options_with_defaults.input) {
        .checkbox => |*checkbox_options| {
            options_with_defaults.label.class = checkbox_field_label_class;
            applyInputDefaults(checkbox_options);
        },
        .text => |*text_options| {
            applyInputDefaults(text_options);
        },
        .email => |*email_options| {
            applyInputDefaults(email_options);
        },
        .password => |*password_options| {
            applyInputDefaults(password_options);
        },
        .number => |*number_options| {
            applyInputDefaults(number_options);
        },
        .time => |*time_options| {
            applyInputDefaults(time_options);
        },
        .select => |*select_options| {
            applyInputDefaults(select_options);
        },
    }

    try form.writeField(writer, name, options_with_defaults);
}

const submit_options: mantle_view_helpers.SubmitOptions = .{ .class = "rounded outline-1 focus:outline-2 outline-gray-300 dark:outline-gray-600 cursor-pointer" };

pub fn writeSubmit(writer: *std.Io.Writer, value: []const u8) !void {
    try mantle_view_helpers.writeSubmit(writer, value, submit_options);
}

pub fn beginCenteredPageContent(writer: *std.Io.Writer) !void {
    try mantle_view_helpers.writeHtmlTag(
        writer,
        "div",
        .{
            .class = "my-4 flex flex-col md:w-2xl mx-8 md:mx-auto justify-self-center",
        },
        .{},
    );
}

pub fn endCenteredPageContent(writer: *std.Io.Writer) !void {
    try writer.writeAll("</div>");
}

pub fn uuidToHex(uuid: []const u8) ![36]u8 {
    return try pg.uuidToHex(uuid);
}

pub fn writeImportMap(writer: *std.Io.Writer) !void {
    var import_map = mantle.ImportMap.init(writer);
    try import_map.begin();
    try import_map.writeEntries(assets.import_map_entries);
    switch (environment_options.environment) {
        .development => {
            try import_map.writeEntry(.init("react", "https://esm.sh/react@^19.1.1?dev"));
            try import_map.writeEntry(.init("react-dom", "https://esm.sh/react-dom@^19.1.1?dev"));
            try import_map.writeEntry(.init("react-dom/", "https://esm.sh/react-dom@^19.1.1&dev/"));
            try import_map.writeEntry(.init("react-map-gl", "https://esm.sh/react-map-gl@^8.0.4?dev&deps=react@^19.1.1,react-dom@19.1.1"));
            try import_map.writeEntry(.init("react-map-gl/", "https://esm.sh/react-map-gl@^8.0.4&dev&deps=react@^19.1.1,react-dom@19.1.1/"));
            try import_map.writeEntry(.init("react-icons/", "https://esm.sh/react-icons@^5.5.0&dev&deps=react@^19.1.1,react-dom@19.1.1/"));
            try import_map.writeEntry(.init("@tanstack/react-query", "https://esm.sh/@tanstack/react-query@^5.90.7?dev&deps=react@^19.1.1,react-dom@19.1.1"));
        },
        .production => {
            try import_map.writeEntry(.init("react", "https://esm.sh/react@^19.1.1"));
            try import_map.writeEntry(.init("react-dom", "https://esm.sh/react-dom@^19.1.1"));
            try import_map.writeEntry(.init("react-dom/", "https://esm.sh/react-dom@^19.1.1/"));
            try import_map.writeEntry(.init("react-map-gl", "https://esm.sh/react-map-gl@^8.0.4&deps=react@^19.1.1,react-dom@19.1.1"));
            try import_map.writeEntry(.init("react-map-gl/", "https://esm.sh/react-map-gl@^8.0.4&deps=react@^19.1.1,react-dom@19.1.1/"));
            try import_map.writeEntry(.init("react-icons/", "https://esm.sh/react-icons@^5.5.0&deps=react@^19.1.1,react-dom@19.1.1/"));
            try import_map.writeEntry(.init("@tanstack/react-query", "https://esm.sh/@tanstack/react-query@^5.90.7&deps=react@^19.1.1,react-dom@19.1.1"));
        },
    }
    try import_map.writeEntry(.init("htm", "https://esm.sh/*htm@^3.1.1"));
    try import_map.writeEntry(.init("htm/", "https://esm.sh/*htm@^3.1.1/"));
    try import_map.writeEntry(.init("maplibre-gl", "https://esm.sh/maplibre-gl@^5.7.0"));
    try import_map.writeEntry(.init("classnames", "https://esm.sh/classnames@^2.5.1"));
    try import_map.writeEntry(.init("camelize", "https://esm.sh/camelize@^1.0.1"));
    try import_map.writeEntry(.init("to-snake-case", "https://esm.sh/to-snake-case@^1.0.0"));
    try import_map.writeEntry(.init("axios", "https://esm.sh/axios@^1.13.2"));
    try import_map.writeEntry(.init("qs", "https://esm.sh/qs@^6.14.0"));
    try import_map.writeEntry(.init("lodash", "https://esm.sh/lodash@4.17.21"));
    try import_map.writeEntry(.init("lodash/", "https://esm.sh/lodash@4.17.21/"));
    try import_map.end();
}

pub fn writePlaceTag(writer: *std.Io.Writer, place_tag: anytype) !void {
    try mantle_view_helpers.writeHtmlTag(
        writer,
        "div",
        .{
            .class = "inline-block px-1 py-0.5 border rounded border-purple-600 dark:border-purple-500 hover:background-purple-200 dark:hover:background-purple-100",
        },
        .{},
    );
    try mantle.cgi_escape.writeEscapedHtml(writer, place_tag.associations.tag.attributes.name);
    try writer.writeAll("</div>");
}

pub fn writeDt(writer: *std.Io.Writer, body: []const u8) !void {
    try mantle_view_helpers.writeHtmlTag(writer, "dt", .{ .class = "font-bold" }, .{});
    try mantle.cgi_escape.writeEscapedHtml(writer, body);
    try writer.writeAll("</dt>");
}

pub const dd_class = "mb-4";
pub const DdOptions = struct { class: []const u8 = dd_class };

pub fn writeDd(writer: *std.Io.Writer, body: []const u8, options: DdOptions) !void {
    try beginDd(writer, options);
    try mantle.cgi_escape.writeEscapedHtml(writer, body);
    try endDd(writer);
}

pub fn beginDd(writer: *std.Io.Writer, options: DdOptions) !void {
    try mantle_view_helpers.writeHtmlTag(writer, "dd", options, .{});
}

pub fn endDd(writer: *std.Io.Writer) !void {
    try writer.writeAll("</dd>");
}
