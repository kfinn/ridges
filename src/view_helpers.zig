const std = @import("std");

const mantle = @import("mantle");

pub fn writeLinkTo(writer: *std.Io.Writer, body: []const u8, url: []const u8) std.Io.Writer.Error!void {
    try writer.print("<a class=\"text-blue-600 dark:text-blue-500 hover:underline\" href=\"{s}\">{s}</a>", .{ url, body });
}

pub fn writeFieldErrors(writer: *std.Io.Writer, errors: anytype, field: @TypeOf(errors).Field) std.Io.Writer.Error!void {
    try writeErrors(writer, errors.field_errors.get(field).items);
}

pub fn writeErrors(writer: *std.Io.Writer, errors: []mantle.validation.Error) std.Io.Writer.Error!void {
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

pub fn writeH1(writer: *std.Io.Writer, body: []const u8) std.Io.Writer.Error!void {
    try writer.print("<h1 class=\"text-xl\">{s}</h1>", .{body});
}

pub fn writeH2(writer: *std.Io.Writer, body: []const u8) std.Io.Writer.Error!void {
    try beginH2(writer);
    try mantle.cgi_escape.writeEscapedHtml(writer, body);
    try endH2(writer);
}

pub fn beginH2(writer: *std.Io.Writer) std.Io.Writer.Error!void {
    try writer.writeAll("<h2 class=\"text-lg\">");
}

pub fn endH2(writer: *std.Io.Writer) std.Io.Writer.Error!void {
    try writer.writeAll("</h2>");
}

pub fn beginUl(writer: *std.Io.Writer) std.Io.Writer.Error!void {
    try writer.writeAll("<ul class=\"list-disc\">");
}

pub fn endUl(writer: *std.Io.Writer) std.Io.Writer.Error!void {
    try writer.writeAll("</ul>");
}

pub fn beginForm(writer: *std.Io.Writer) std.Io.Writer.Error!void {
    try writer.writeAll("<form class=\"flex flex-col items-stretch space-y-2\" method=\"POST\">");
}

pub fn endForm(writer: *std.Io.Writer) std.Io.Writer.Error!void {
    try writer.writeAll("</form>");
}

pub const FieldOpts = struct {
    autofocus: ?bool = null,
    type: ?[]const u8 = null,
};

pub fn writeRecordField(
    writer: *std.Io.Writer,
    model: anytype,
    errors: *mantle.validation.RecordErrors(@TypeOf(model)),
    comptime name: std.meta.FieldEnum(@TypeOf(model)),
    opts: FieldOpts,
) !void {
    try writeField(
        writer,
        @field(model, @tagName(name)),
        errors.field_errors.get(name).items,
        @tagName(name),
        opts,
    );
}

pub fn writeField(
    writer: *std.Io.Writer,
    value: ?[]const u8,
    errors: []mantle.validation.Error,
    comptime name: []const u8,
    opts: FieldOpts,
) !void {
    const title_case_field_name = comptime mantle.inflector.comptimeHumanize(name);

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

pub fn writeInput(writer: *std.Io.Writer, name: []const u8, opts: InputOpts) std.Io.Writer.Error!void {
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

pub fn writeSubmit(writer: *std.Io.Writer, value: []const u8) !void {
    try writer.writeAll("<input type=\"submit\" class=\"rounded outline-1 focus:outline-2 outline-gray-300 dark:outline-gray-600 cursor-pointer\" value=\"");
    try mantle.cgi_escape.writeEscapedHtmlAttribute(writer, value);
    try writer.writeAll("\" />");
}
