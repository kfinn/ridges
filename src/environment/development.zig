const std = @import("std");

const ridges = @import("../ridges.zig");

pub const config: ridges.App.Config = .{
    .db = .{
        .connect = .{
            .host = "db",
            .port = 5432,
        },
        .auth = .{
            .username = "ridges",
            .password = "password",
            .database = "ridges",
            .application_name = "Ridges",
        },
    },
    .session = .{
        .cookie_secret_key = "de86040470140bcaa6cf34b4dc34edf3",
    },
    .httpz = .{
        .port = 5882,
        .request = .{
            .max_query_count = 1024,
            .max_form_count = 1024,
        },
    },
};
