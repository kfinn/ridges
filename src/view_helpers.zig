const std = @import("std");

const mantle = @import("mantle");
pub const mantle_view_helpers = mantle.view_helpers;
const pg = @import("pg");

const ridges = @import("ridges.zig");

pub const LinkOptions = struct { class: ?[]const u8 = null };
pub const link_options: LinkOptions = .{ .class = "text-blue-600 dark:text-blue-500 hover:underline" };

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

pub const H1Options = struct { class: ?[]const u8 = null };
pub const h1_options: H1Options = .{ .class = "text-xl" };

pub fn writeH1(writer: *std.Io.Writer, body: []const u8, options: H1Options) !void {
    try beginH1(writer, options);
    try mantle.cgi_escape.writeEscapedHtml(writer, body);
    try endH1(writer);
}

pub fn endH1(writer: *std.Io.Writer) !void {
    try writer.writeAll("</h1>");
}

pub fn beginH1(writer: *std.Io.Writer, options: H1Options) !void {
    var merged_options: H1Options = h1_options;
    if (options.class) |class| {
        merged_options.class = class;
    }

    try mantle_view_helpers.writeHtmlTag(writer, "h1", merged_options, .{});
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
    .label = label_options,
    .input = .{ .input = .{ .class = field_input_class } },
    .errors = errors_options,
};
const label_options: mantle_view_helpers.LabelOptions = .{ .class = "flex flex-col items-stretch space-y-1" };
const field_input_class: []const u8 = "rounded outline-1 focus:outline-2 outline-gray-300 dark:outline-gray-600 dark:scheme-dark";

pub fn writeFormField(
    writer: *std.Io.Writer,
    form: anytype,
    comptime name: anytype,
    options: mantle_view_helpers.FieldOptions,
) !void {
    var merged_options: mantle_view_helpers.FieldOptions = field_options;
    if (options.label.name) |label_options_class_override| {
        merged_options.label.name = label_options_class_override;
    }
    switch (options.input) {
        .input => |input_options| {
            if (options.label.class) |label_options_class_override| {
                merged_options.label.class = label_options_class_override;
            }
            if (input_options.autofocus) |input_options_autofocus_override| {
                merged_options.input.input.autofocus = input_options_autofocus_override;
            }
            if (input_options.type) |input_options_type_override| {
                merged_options.input.input.type = input_options_type_override;
            }
            if (input_options.class) |input_options_class_override| {
                merged_options.input.input.class = input_options_class_override;
            }
            if (input_options.autocomplete) |input_options_class_override| {
                merged_options.input.input.autocomplete = input_options_class_override;
            }
        },
        .select => |select_options| {
            if (options.label.class) |label_options_class_override| {
                merged_options.label.class = label_options_class_override;
            }
            merged_options.input = .{ .select = select_options };
            if (select_options.class == null) {
                merged_options.input.select.class = field_input_class;
            }
        },
        .checkbox => |checkbox_options| {
            if (options.label.class) |label_options_class_override| {
                merged_options.label.class = label_options_class_override;
            }
            merged_options.label.class = "flex justify-start items-center space-x-1";
            merged_options.input = .{ .checkbox = checkbox_options };
            if (checkbox_options.class == null) {
                merged_options.input.checkbox.class = field_input_class;
            }
        },
    }

    try form.writeField(writer, name, merged_options);
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
