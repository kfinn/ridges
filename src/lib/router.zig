const std = @import("std");
const assert = std.debug.assert;

const httpz = @import("httpz");

const ControllerContext = @import("ControllerContext.zig").ControllerContext;
const inflector = @import("inflector.zig");
const cgi_escape = @import("cgi_escape.zig");

const RouterError = error{unknown};

fn RouteParams(comptime param_names: []const [:0]const u8) type {
    comptime {
        var fields: [param_names.len]std.builtin.Type.StructField = undefined;
        for (param_names, 0..) |field_name, index| {
            fields[index] = .{
                .name = field_name ++ "",
                .type = []const u8,
                .default_value_ptr = null,
                .is_comptime = false,
                .alignment = 0,
            };
        }
        const decls = [_]std.builtin.Type.Declaration{};

        return @Type(
            std.builtin.Type{
                .@"struct" = .{
                    .layout = .auto,
                    .fields = &fields,
                    .decls = &decls,
                    .is_tuple = false,
                },
            },
        );
    }
}

fn comptimeExtendParamNames(comptime param_names: []const [:0]const u8, comptime new_param_name: [:0]const u8) []const [:0]const u8 {
    comptime {
        var param_names_builder: [param_names.len + 1][:0]const u8 = undefined;
        var index = 0;
        while (index < param_names.len) : (index += 1) {
            param_names_builder[index] = param_names[index];
        }
        param_names_builder[param_names.len] = new_param_name;
        const final_param_names = param_names_builder;
        return &final_param_names;
    }
}

fn ExtendedRouteParams(comptime OldRouteParmas: type, comptime new_param_name: [:0]const u8) type {
    const param_names = comptimeExtendParamNames(std.meta.fieldNames(OldRouteParmas), new_param_name);
    return RouteParams(param_names);
}

fn extendRouteParams(comptime OldRouteParams: type, comptime new_param_name: [:0]const u8, old_route_params: OldRouteParams, new_param_value: []const u8) ExtendedRouteParams(OldRouteParams, new_param_name) {
    var extended_route_params: ExtendedRouteParams(OldRouteParams, new_param_name) = undefined;
    inline for (std.meta.fieldNames(OldRouteParams)) |field_name| {
        @field(extended_route_params, field_name) = @field(old_route_params, field_name);
    }
    @field(extended_route_params, new_param_name) = new_param_value;
    return extended_route_params;
}

pub fn Router(comptime App: type, comptime routes_entries_param: []const RoutesEntry) type {
    return struct {
        fn renderServerError(response: *httpz.Response) void {
            response.status = 500;
            response.body = "Internal Error";
        }

        const empty_param_names: [0][:0]const u8 = .{};
        pub fn handle(self: *@This(), request: *httpz.Request, response: *httpz.Response) void {
            if (request.url.path[0] != '/') {
                renderServerError(response);
                return;
            }

            const handled = self.handleRouteEntries(&empty_param_names, request, response, routes_entries_param, request.url.path[1..], .{}) catch |err| {
                std.log.info("error: {}", .{err});
                renderServerError(response);
                return;
            };
            if (!handled) {
                response.status = 404;
                response.body = "Not Found";
            }
        }

        fn handleRouteEntries(self: *@This(), comptime route_param_names: []const [:0]const u8, request: *httpz.Request, response: *httpz.Response, comptime routes_entries: []const RoutesEntry, path: []const u8, route_params: RouteParams(route_param_names)) !bool {
            inline for (routes_entries) |routes_entry| {
                const handled = switch (routes_entry) {
                    .resource => |resource| try self.handleResource(route_param_names, request, response, resource, path, route_params),
                    .resources => |resources| try self.handleResources(route_param_names, request, response, resources, path, route_params),
                    else => return RouterError.unknown,
                };
                if (handled) {
                    return true;
                }
            }
            return false;
        }

        fn handleResource(self: *@This(), comptime route_param_names: []const [:0]const u8, request: *httpz.Request, response: *httpz.Response, comptime resource: Resource, path: []const u8, route_params: RouteParams(route_param_names)) !bool {
            const first_path_segment, const rest_path_segments = splitFirstPathSegment(path);

            if (!std.mem.eql(u8, resource.name, first_path_segment)) {
                return false;
            }

            if (rest_path_segments.len == 0) {
                if (request.method == .GET and std.meta.hasFn(resource.Controller, "show")) {
                    var context = try App.ControllerContext.init(
                        self.app(),
                        request,
                        response,
                    );
                    defer context.deinit();

                    const show_type_info = @typeInfo(@TypeOf(resource.Controller.show)).@"fn";
                    comptime {
                        assert(show_type_info.params.len >= 1);
                        assert(show_type_info.params[0].type.? == *@TypeOf(context));
                    }
                    if (show_type_info.params.len == 1) {
                        try resource.Controller.show(&context);
                        return true;
                    }
                    comptime assert(show_type_info.params.len == 2);
                    const ShowParams = show_type_info.params[1].type.?;
                    var show_params: ShowParams = undefined;
                    inline for (comptime std.meta.fieldNames((ShowParams))) |field| {
                        @field(show_params, field) = @field(route_params, field);
                    }
                    try resource.Controller.show(&context, show_params);
                    return true;
                } else {
                    return false;
                }
            }
            if (resource.routes) |child_routes| {
                return try self.handleRouteEntries(request, response, child_routes, rest_path_segments, route_params);
            }
            return false;
        }

        fn handleResources(self: *@This(), comptime route_param_names: []const [:0]const u8, request: *httpz.Request, response: *httpz.Response, comptime resources: Resources, path: []const u8, route_params: RouteParams(route_param_names)) !bool {
            const first_path_segment, const path_segments_after_name = splitFirstPathSegment(path);

            if (!std.mem.eql(u8, resources.name, first_path_segment) or path_segments_after_name.len == 0) {
                return false;
            }

            const escaped_id_path_segment, const rest_path_segments = splitFirstPathSegment(path_segments_after_name);

            const id_path_segment = try cgi_escape.unescapeUriComponentAlloc(request.arena, escaped_id_path_segment);
            defer request.arena.free(id_path_segment);

            if (rest_path_segments.len == 0) {
                if (request.method == .GET and std.meta.hasFn(resources.Controller, "show")) {
                    var context = try App.ControllerContext.init(
                        self.app(),
                        request,
                        response,
                    );
                    defer context.deinit();

                    const show_type_info = @typeInfo(@TypeOf(resources.Controller.show)).@"fn";
                    comptime {
                        assert(show_type_info.params.len == 2);
                        assert(show_type_info.params[0].type.? == *@TypeOf(context));
                    }
                    const ShowParams = show_type_info.params[1].type.?;
                    var show_params: ShowParams = undefined;

                    const route_params_with_id = extendRouteParams(@TypeOf(route_params), "id", route_params, id_path_segment);
                    inline for (comptime std.meta.fieldNames((ShowParams))) |field| {
                        @field(show_params, field) = @field(route_params_with_id, field);
                    }
                    try resources.Controller.show(&context, show_params);
                    return true;
                } else {
                    return false;
                }
            }
            if (resources.routes) |child_routes| {
                const param_name = comptime std.fmt.comptimePrint("{s}_id", .{inflector.comptimeSingularize(resources.name)});
                const nested_route_param_names = comptime comptimeExtendParamNames(route_param_names, param_name);
                const route_params_with_id = extendRouteParams(@TypeOf(route_params), param_name, route_params, id_path_segment);
                return try self.handleRouteEntries(nested_route_param_names, request, response, child_routes, rest_path_segments, route_params_with_id);
            }
            return false;
        }

        fn app(self: *@This()) *App {
            return @alignCast(@fieldParentPtr("router", self));
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
    routes: ?[]const RoutesEntry,
};

pub const Resources = struct {
    name: []const u8,
    Controller: type,
    routes: ?[]const RoutesEntry = null,
};

pub const Resource = struct {
    name: []const u8,
    Controller: type,
    routes: ?[]const RoutesEntry = null,
};

fn splitFirstPathSegment(path: []const u8) [2][]const u8 {
    var iterator = std.mem.splitScalar(u8, path, '/');
    return .{ iterator.first(), iterator.rest() };
}
