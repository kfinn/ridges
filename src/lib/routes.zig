const std = @import("std");
const assert = std.debug.assert;
const httpz = @import("httpz");

pub const Params = union(enum) {
    const ParamsThis = @This();

    some: struct {
        name: []const u8,
        value: []const u8,
        rest: *ParamsThis,
    },
    none,

    const FindParamError = error{NotFound};

    pub fn find(self: *ParamsThis, name: []const u8) ![]const u8 {
        switch (self) {
            .some => |some_param| {
                if (std.mem.eql(u8, some_param.name, name)) {
                    some_param.value;
                } else {
                    some_param.rest.find(name);
                }
            },
            else => FindParamError.NotFound,
        }
    }
};

pub fn handleRoutesEntries(comptime routes_entries: []const RoutesEntry, request: *httpz.Request, response: *httpz.Response, path: []const u8, params: Params) !bool {
    inline for (routes_entries) |routes_entry| {
        if (try routes_entry.handle(request, response, path, params)) {
            return true;
        }
    }
    return false;
}

pub const RoutesEntry = union(enum) {
    namespace: Namespace,
    resource: Resource,
    resources: Resources,

    fn handle(self: *const @This(), request: *httpz.Request, response: *httpz.Response, path: []const u8, params: Params) !bool {
        return switch (self.*) {
            .namespace => |namespace| try namespace.handle(request, response, path, params),
            .resource => |resource| try resource.handle(request, response, path, params),
            .resources => |resources| try resources.handle(request, response, path, params),
        };
    }
};

pub const Namespace = struct {
    name: []const u8,
    routes: ?[]RoutesEntry,

    fn handle(self: *const @This(), request: *httpz.Request, response: *httpz.Response, path: []const u8, params: Params) !bool {
        const first_path_segment, const rest_path_segments = splitPathSegments(path);

        if (std.mem.eql(u8, self.name, first_path_segment)) {
            return handleRoutesEntries(self.routes, request, response, rest_path_segments, params);
        }
        return false;
    }
};

fn splitPathSegments(path: []const u8) [2][]const u8 {
    var iterator = std.mem.splitScalar(u8, path, '/');
    return .{ iterator.first(), iterator.rest() };
}

pub const Resources = struct {
    name: []const u8,
    controller: type,
    routes: ?[]RoutesEntry,

    fn handle(self: *const @This(), request: *httpz.Request, response: *httpz.Response, path: []const u8, params: Params) !bool {
        const first_path_segment, const rest_path_segments = splitPathSegments(path);

        if (rest_path_segments.len == 0) {
            if (request.method == .GET and @hasDecl(self.controller, "index")) {
                const index_type_info = @typeInfo(@TypeOf(self.controller.index));
                switch (index_type_info) {
                    .@"fn" => {},
                    else => return false,
                }
            }
        }
        if (std.mem.eql(u8, self.name, first_path_segment)) {
            return handleRoutesEntries(self.routes, request, response, rest_path_segments, params);
        }
        return false;
    }
};
pub const Resource = struct {
    name: []const u8,
    Controller: type,
    routes: ?[]RoutesEntry,

    fn handle(self: *const @This(), request: *httpz.Request, response: *httpz.Response, path: []const u8, params: Params) !bool {
        const first_path_segment, const rest_path_segments = splitPathSegments(path);

        if (!std.mem.eql(u8, self.name, first_path_segment)) {
            return false;
        }

        if (rest_path_segments.len == 0) {
            if (request.method == .GET and std.meta.hasFn(self.Controller, "show")) {
                const show_type_info = @typeInfo(@TypeOf(self.Controller.show)).@"fn";
                assert(show_type_info.params.len >= 2);
                assert(show_type_info.params[0].type.? == *httpz.Request);
                assert(show_type_info.params[1].type.? == *httpz.Response);
                if (show_type_info.params.len == 2) {
                    try self.Controller.show(request, response);
                    return true;
                }
                assert(show_type_info.params.len == 3);
                const ShowParams = show_type_info.params[2].type.?;
                const show_params: ShowParams = undefined;
                inline for (std.meta.fieldNames((ShowParams))) |field| {
                    @field(show_params, field) = params.find(field);
                }
                try self.Controller.show(request, response, show_params);
            } else {
                return false;
            }
        } else {
            return false;
        }
    }
};
