const std = @import("std");
const mantle = @import("mantle");

pub fn writeLinkTo(writer: anytype, body: []const u8, url: []const u8) @TypeOf(writer).Error!void {
    try writer.print("<a href=\"{s}\">{s}</a>", .{ url, body });
}

pub fn writeFieldErrors(writer: anytype, errors: anytype, field: @TypeOf(errors).Field) @TypeOf(writer).Error!void {
    const field_errors = errors.field_errors.get(field).items;
    if (field_errors.len == 0) return;

    try writer.writeAll("<span style=\"color: red\">");

    var requires_leading_comma = false;
    for (field_errors) |field_error| {
        if (requires_leading_comma) try writer.writeAll(", ");
        try mantle.cgi_escape.writeEscapedHtml(writer, field_error.description);
        requires_leading_comma = true;
    }

    try writer.writeAll("</span>");
}
