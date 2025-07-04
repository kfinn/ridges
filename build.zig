const std = @import("std");
const ezig = @import("ezig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/lib/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/app/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_mod.addImport("ridges_lib", lib_mod);

    const httpz = b.dependency("httpz", .{
        .target = target,
        .optimize = optimize,
    }).module("httpz");
    lib_mod.addImport("httpz", httpz);
    exe_mod.addImport("httpz", httpz);

    const pg = b.dependency("pg", .{
        .target = target,
        .optimize = optimize,
    }).module("pg");
    lib_mod.addImport("pg", pg);
    exe_mod.addImport("pg", pg);

    const ezig_templates_mod = ezig.addEzigTemplatesImport(exe_mod, .{ .path = "src/app/views" });
    ezig_templates_mod.addImport("app", exe_mod);
    ezig_templates_mod.addImport("ridges_lib", lib_mod);

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "ridges",
        .root_module = lib_mod,
    });

    b.installArtifact(lib);

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

    const lib_unit_tests = b.addTest(.{
        .root_module = lib_mod,
    });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
