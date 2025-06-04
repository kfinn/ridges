const std = @import("std");
const assert = std.debug.assert;

const httpz = @import("httpz");

const ControllerContext = @import("controller_context.zig").ControllerContext;

pub const RouteParams = union(enum) {
    const RouteParamsThis = @This();

    some: struct {
        name: []const u8,
        value: []const u8,
        rest: *const RouteParamsThis,
    },
    none,

    const FindParamError = error{NotFound};

    pub fn find(self: *const RouteParamsThis, name: []const u8) ![]const u8 {
        switch (self.*) {
            .some => |some_param| {
                if (std.mem.eql(u8, some_param.name, name)) {
                    return some_param.value;
                } else {
                    return some_param.rest.find(name);
                }
            },
            else => return FindParamError.NotFound,
        }
    }
};

const RouterError = error{unknown};

pub fn Router(comptime AppReference: type, comptime routes_entries_param: []const RoutesEntry) type {
    return struct {
        app_reference: AppReference,

        const AppControllerContext = ControllerContext(AppReference.App);

        fn renderServerError(response: *httpz.Response) void {
            response.status = 500;
            response.body = "Internal Error";
        }

        pub fn handle(self: *@This(), request: *httpz.Request, response: *httpz.Response) void {
            if (request.url.path[0] != '/') {
                renderServerError(response);
                return;
            }

            const handled = self.handleRouteEntries(request, response, routes_entries_param, request.url.path[1..], .none) catch {
                renderServerError(response);
                return;
            };
            if (!handled) {
                response.status = 404;
                response.body = "Not Found";
            }
        }

        fn handleRouteEntries(self: *@This(), request: *httpz.Request, response: *httpz.Response, comptime routes_entries: []const RoutesEntry, path: []const u8, route_params: RouteParams) !bool {
            inline for (routes_entries) |routes_entry| {
                const handled = switch (routes_entry) {
                    .resource => |resource| try self.handleResource(request, response, resource, path, route_params),
                    .resources => |resources| try self.handleResources(request, response, resources, path, route_params),
                    else => return RouterError.unknown,
                };
                if (handled) {
                    return true;
                }
            }
            return false;
        }

        fn handleResource(self: *@This(), request: *httpz.Request, response: *httpz.Response, comptime resource: Resource, path: []const u8, route_params: RouteParams) !bool {
            const first_path_segment, const rest_path_segments = splitPathSegments(path);

            if (!std.mem.eql(u8, resource.name, first_path_segment)) {
                return false;
            }

            if (rest_path_segments.len == 0) {
                if (request.method == .GET and std.meta.hasFn(resource.Controller, "show")) {
                    const controller = resource.Controller{ .controller_context = .{ .app = self.app_reference.app(), .request = request, .response = response } };

                    const show_type_info = @typeInfo(@TypeOf(resource.Controller.show)).@"fn";
                    comptime {
                        assert(show_type_info.params.len >= 1);
                        assert(show_type_info.params[0].type.? == *const resource.Controller);
                    }
                    if (show_type_info.params.len == 1) {
                        try controller.show();
                        return true;
                    }
                    comptime assert(show_type_info.params.len == 2);
                    const ShowParams = show_type_info.params[1].type.?;
                    const show_params: ShowParams = undefined;
                    inline for (std.meta.fieldNames((ShowParams))) |field| {
                        @field(show_params, field) = route_params.find(field);
                    }
                    try controller.show(show_params);
                } else {
                    return false;
                }
            } else {
                return false;
            }
        }

        fn handleResources(self: *@This(), request: *httpz.Request, response: *httpz.Response, comptime resources: Resources, path: []const u8, route_params: RouteParams) !bool {
            const first_path_segment, const path_segments_after_name = splitPathSegments(path);

            if (!std.mem.eql(u8, resources.name, first_path_segment) or path_segments_after_name.len == 0) {
                return false;
            }

            const id_path_segment, const rest_path_segments = splitPathSegments(path_segments_after_name);

            if (rest_path_segments.len == 0) {
                if (request.method == .GET and std.meta.hasFn(resources.Controller, "show")) {
                    const controller = resources.Controller{ .controller_context = .{ .app = self.app_reference.app(), .request = request, .response = response } };

                    const show_type_info = @typeInfo(@TypeOf(resources.Controller.show)).@"fn";
                    comptime {
                        assert(show_type_info.params.len == 2);
                        assert(show_type_info.params[0].type.? == *const resources.Controller);
                    }
                    const ShowParams = show_type_info.params[1].type.?;
                    var show_params: ShowParams = undefined;
                    const route_params_with_id = RouteParams{ .some = .{ .name = "id", .value = id_path_segment, .rest = &route_params } };
                    inline for (comptime std.meta.fieldNames((ShowParams))) |field| {
                        @field(show_params, field) = try route_params_with_id.find(field);
                    }
                    try controller.show(show_params);
                    return true;
                } else {
                    return false;
                }
            }
            return false;
        }
    };
}

pub const RoutesEntry = union(enum) {
    namespace: Namespace,
    resource: Resource,
    resources: Resources,
};

pub const Namespace = struct {
    name: []const u8,
    routes: ?[]RoutesEntry,
};

fn splitPathSegments(path: []const u8) [2][]const u8 {
    var iterator = std.mem.splitScalar(u8, path, '/');
    return .{ iterator.first(), iterator.rest() };
}

pub const Resources = struct {
    name: []const u8,
    Controller: type,
    routes: ?[]RoutesEntry,

    // fn handle(self: *const @This(), request: *httpz.Request, response: *httpz.Response, path: []const u8, route_params: RouteParams) !bool {
    //     const first_path_segment, const rest_path_segments = splitPathSegments(path);

    //     if (rest_path_segments.len == 0) {
    //         if (request.method == .GET and @hasDecl(self.controller, "index")) {
    //             const index_type_info = @typeInfo(@TypeOf(self.controller.index));
    //             switch (index_type_info) {
    //                 .@"fn" => {},
    //                 else => return false,
    //             }
    //         }
    //     }
    //     if (std.mem.eql(u8, self.name, first_path_segment)) {
    //         return handleRoutesEntries(self.routes, request, response, rest_path_segments, route_params);
    //     }
    //     return false;
    // }
};
pub const Resource = struct {
    name: []const u8,
    Controller: type,
    routes: ?[]RoutesEntry,
};
