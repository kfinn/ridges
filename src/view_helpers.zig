const std = @import("std");

const mantle = @import("mantle");
pub const mantle_view_helpers = mantle.view_helpers;

pub fn writeLinkTo(writer: *std.Io.Writer, body: []const u8, url: []const u8) !void {
    try mantle_view_helpers.writeHtmlTag(writer, "a", .{ .class = "text-blue-600 dark:text-blue-500 hover:underline", .href = url }, .{});
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

pub fn writeH1(writer: *std.Io.Writer, body: []const u8) !void {
    try mantle_view_helpers.writeHtmlTag(writer, "h1", .{ .class = "text-xl" }, .{});
    try mantle.cgi_escape.writeEscapedHtml(writer, body);
    try writer.writeAll("</h1>");
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

pub fn beginForm(writer: *std.Io.Writer, form: anytype) !void {
    try form.beginForm(writer, .{ .class = "flex flex-col items-stretch space-y-2" });
}

pub fn endForm(writer: *std.Io.Writer, form: anytype) !void {
    try form.endForm(writer);
}

pub const field_options: mantle_view_helpers.FieldOptions = .{
    .label = label_options,
    .input = input_options,
};
const label_options: mantle_view_helpers.LabelOptions = .{ .class = "flex flex-col items-stretch space-y-1" };
const input_options: mantle_view_helpers.InputOptions = .{ .class = "rounded outline-1 focus:outline-2 outline-gray-300 dark:outline-gray-600" };

pub fn writeFormField(writer: *std.Io.Writer, form: anytype, comptime name: std.meta.FieldEnum(@TypeOf(form.model)), options: mantle_view_helpers.FieldOptions) !void {
    var merged_options: mantle_view_helpers.FieldOptions = field_options;
    if (options.label.class) |label_options_class_override| {
        merged_options.label.class = label_options_class_override;
    }
    if (options.input.autofocus) |input_options_autofocus_override| {
        merged_options.input.autofocus = input_options_autofocus_override;
    }
    if (options.input.type) |input_options_type_override| {
        merged_options.input.type = input_options_type_override;
    }
    if (options.input.class) |input_options_class_override| {
        merged_options.input.class = input_options_class_override;
    }

    try form.writeField(writer, name, merged_options);
}

const submit_options: mantle_view_helpers.SubmitOptions = .{ .class = "rounded outline-1 focus:outline-2 outline-gray-300 dark:outline-gray-600 cursor-pointer" };

pub fn writeSubmit(writer: *std.Io.Writer, value: []const u8) !void {
    try mantle_view_helpers.writeSubmit(writer, value, submit_options);
}
