const std = @import("std");
const mantle = @import("mantle");

pub fn writeLinkTo(writer: anytype, body: []const u8, url: []const u8) @TypeOf(writer).Error!void {
    try writer.print("<a href=\"{s}\">{s}</a>", .{ url, body });
}

pub fn writeFieldErrors(writer: anytype, errors: anytype, field: @TypeOf(errors).Field) @TypeOf(writer).Error!void {
    try writeErrors(writer, errors.field_errors.get(field).items);
}

pub fn writeErrors(writer: anytype, errors: []mantle.validation.Error) @TypeOf(writer).Error!void {
    if (errors.len == 0) {
        return;
    }

    try writer.writeAll("<span class=\"text-red-600 dark:text-red-500\">");

    var requires_leading_comma = false;
    for (errors) |validation_error| {
        if (requires_leading_comma) try writer.writeAll(", ");
        try mantle.cgi_escape.writeEscapedHtml(writer, validation_error.description);
        requires_leading_comma = true;
    }

    try writer.writeAll("</span>");
}

pub fn writeH1(writer: anytype, body: []const u8) @TypeOf(writer).Error!void {
    try writer.print("<h1 class=\"text-xl\">{s}</h1>", .{body});
}

pub fn writeH2(writer: anytype, body: []const u8) @TypeOf(writer).Error!void {
    try writer.print("<h2 class=\"text-lg\">{s}</h1>", .{body});
}

pub fn beginUl(writer: anytype) @TypeOf(writer).Error!void {
    try writer.writeAll("<ul class=\"list-disc\">");
}

pub fn endUl(writer: anytype) @TypeOf(writer).Error!void {
    try writer.writeAll("</ul>");
}

pub fn beginForm(writer: anytype) @TypeOf(writer).Error!void {
    try writer.writeAll("<form class=\"flex flex-col items-stretch space-y-2\" action=\".\" method=\"POST\">");
}

pub fn endForm(writer: anytype) @TypeOf(writer).Error!void {
    try writer.writeAll("</form>");
}

pub const FieldOpts = struct {
    autofocus: ?bool = null,
    type: ?[]const u8 = null,
};

pub fn writeField(writer: anytype, value: ?[]const u8, errors: []mantle.validation.Error, comptime name: []const u8, opts: FieldOpts) !void {
    const title_case_field_name = comptime mantle.inflector.comptimeTitleize(name);

    try writer.writeAll("<label for=\"");
    try mantle.cgi_escape.writeEscapedHtmlAttribute(writer, name);
    try writer.writeAll("\" class=\"flex flex-col items-stretch space-y-1\"><span>");
    try mantle.cgi_escape.writeEscapedHtml(writer, title_case_field_name);
    try writer.writeAll("</span>");
    try writeInput(writer, name, .{ .autofocus = opts.autofocus, .type = opts.type, .value = value });
    try writer.writeAll("<div>");
    try writeErrors(writer, errors);
    try writer.writeAll("</div>");
    try writer.writeAll("</label>");
}

pub const InputOpts = struct {
    value: ?[]const u8 = null,
    autofocus: ?bool = null,
    type: ?[]const u8 = null,
};

pub fn writeInput(writer: anytype, name: []const u8, opts: InputOpts) @TypeOf(writer).Error!void {
    try writer.writeAll("<input class=\"rounded outline-1 focus:outline-2 outline-gray-300 dark:outline-gray-600\" id=\"");
    try mantle.cgi_escape.writeEscapedHtmlAttribute(writer, name);
    try writer.writeAll("\" name=\"");
    try mantle.cgi_escape.writeEscapedHtmlAttribute(writer, name);
    try writer.writeAll("\"");
    if (opts.value) |value| {
        try writer.writeAll(" value=\"");
        try mantle.cgi_escape.writeEscapedHtmlAttribute(writer, value);
        try writer.writeAll("\"");
    }
    if (opts.autofocus) |autofocus| {
        if (autofocus) {
            try writer.writeAll(" autofocus");
        }
    }
    if (opts.type) |type_opt| {
        try writer.writeAll(" type=\"");
        try mantle.cgi_escape.writeEscapedHtmlAttribute(writer, type_opt);
        try writer.writeAll("\"");
    }
    try writer.writeAll(" />");
}

pub fn writeSubmit(writer: anytype, value: []const u8) !void {
    try writer.writeAll("<input type=\"submit\" class=\"rounded outline-1 focus:outline-2 outline-gray-300 dark:outline-gray-600 cursor-pointer\" value=\"");
    try mantle.cgi_escape.writeEscapedHtmlAttribute(writer, value);
    try writer.writeAll("\" />");
}
