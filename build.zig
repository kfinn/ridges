const std = @import("std");

const ezig = @import("ezig");
const mantle = @import("mantle");
const tailwindcss = @import("tailwindcss");

const environment = @import("src/environment.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const environment_option = b.option(environment.Environment, "environment", "Runtime environment to target");

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const environment_options = b.addOptions();
    environment_options.addOption(
        environment.Environment,
        "environment",
        environment_option orelse environment.Environment.development,
    );

    exe_mod.addOptions("environment", environment_options);

    const httpz_mod = b.dependency("httpz", .{
        .target = target,
        .optimize = optimize,
    }).module("httpz");
    exe_mod.addImport("httpz", httpz_mod);

    const pg_mod = b.dependency("pg", .{
        .target = target,
        .optimize = optimize,
    }).module("pg");
    exe_mod.addImport("pg", pg_mod);

    const mantle_mod = b.dependency("mantle", .{
        .target = target,
        .optimize = optimize,
    }).module("mantle");
    mantle.addMantlePeerImports(mantle_mod, .{ .pg = pg_mod, .httpz = httpz_mod });

    exe_mod.addImport("mantle", mantle_mod);

    const tailwindcss_step = tailwindcss.addTailwindcssStep(b, .{ .input = b.path("src/tailwind.css") });

    const collect_assets_step = b.addWriteFiles();
    _ = collect_assets_step.addCopyFile(tailwindcss_step.output_file, "tailwind/tailwind.css");
    _ = collect_assets_step.addCopyDirectory(b.path("assets"), ".", .{});
    _ = collect_assets_step.addCopyDirectory(
        b.path("js"),
        ".",
        .{ .exclude_extensions = &[_][]const u8{"jsconfig.json"} },
    );

    const assets_mod = mantle.addAssetsImport(exe_mod, .{ .path = collect_assets_step.getDirectory() });

    const ezig_templates_mod = ezig.addEzigTemplatesImport(exe_mod, .{ .path = b.path("src/views") });
    ezig_templates_mod.addImport("app", exe_mod);
    ezig_templates_mod.addImport("mantle", mantle_mod);
    ezig_templates_mod.addImport("assets", assets_mod);

    const exe = b.addExecutable(.{
        .name = "ridges",
        .root_module = exe_mod,
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
