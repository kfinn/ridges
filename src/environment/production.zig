const std = @import("std");

const pg = @import("pg");

const ridges = @import("../ridges.zig");

pub fn buildConfig(_: std.mem.Allocator, env_map: *const std.process.EnvMap) !ridges.App.Config {
    return .{
        .db = .{
            .connect = .{
                .host = env_map.get("DB_CONNECT_HOST").?,
            },
            .auth = .{
                .username = env_map.get("DB_AUTH_USERNAME").?,
                .password = env_map.get("DB_AUTH_PASSWORD").?,
                .database = env_map.get("DB_AUTH_DATABASE").?,
                .application_name = "Ridges",
            },
        },
        .session = .{
            .cookie_secret_key = env_map.get("COOKIE_SECRET_KEY"),
        },
        .httpz = .{
            .port = if (env_map.get("PORT")) |env_port| try std.fmt.parseInt(u16, env_port, 10) else 5882,
            .address = "0.0.0.0",
            .thread_pool = .{
                .count = count: {
                    const web_concurrency_string = env_map.get("WEB_CONCURRENCY") orelse break :count null;
                    const web_concurrency = try std.fmt.parseInt(u16, web_concurrency_string, 10);
                    break :count web_concurrency * 4;
                },
            },
            .request = .{
                .max_query_count = 1024,
                .max_form_count = 1024,
            },
        },
    };
}
