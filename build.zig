const std = @import("std");
const ezig = @import("ezig");
const tailwindcss = @import("tailwindcss");

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

    const tailwindcss_step = tailwindcss.addTailwindcssStep(b, .{ .input = b.path("src/app/tailwind.css") });

    const collect_assets_step = b.addWriteFiles();
    _ = collect_assets_step.addCopyFile(tailwindcss_step.output_file, "tailwind/tailwind.css");
    _ = collect_assets_step.addCopyDirectory(b.path("src/app/assets"), ".", .{});

    const assets_exe = b.addExecutable(.{
        .name = " assets",
        .root_source_file = b.path("src/tools/assets/main.zig"),
        .target = b.graph.host,
    });

    const assets_mod = addAssetsImportExe(
        exe_mod,
        .{ .path = collect_assets_step.getDirectory() },
        assets_exe,
    );

    const ezig_templates_mod = ezig.addEzigTemplatesImport(exe_mod, .{ .path = b.path("src/app/views") });
    ezig_templates_mod.addImport("app", exe_mod);
    ezig_templates_mod.addImport("ridges_lib", lib_mod);
    ezig_templates_mod.addImport("assets", assets_mod);

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

pub const AssetsImportOptions = struct {
    path: std.Build.LazyPath,
    import_name: []const u8 = "assets",
};

fn addAssetsImportExe(module: *std.Build.Module, options: AssetsImportOptions, assets_exe: *std.Build.Step.Compile) *std.Build.Module {
    const b = module.owner;

    const assets_list_only_step = b.addRunArtifact(assets_exe);
    assets_list_only_step.has_side_effects = true;
    assets_list_only_step.addArg("list");
    const assets_list_only_output = assets_list_only_step.addOutputFileArg("assets_list.txt");
    assets_list_only_step.addDirectoryArg(options.path);

    const assets_generate_step = b.addRunArtifact(assets_exe);
    assets_generate_step.addArg("generate");
    const assets_zig_output = assets_generate_step.addOutputFileArg("assets.zig");
    const assets_dir_output = assets_generate_step.addOutputDirectoryArg("assets");
    assets_generate_step.addDirectoryArg(options.path);
    _ = assets_generate_step.addDepFileOutputArg("assets.d");
    assets_generate_step.addFileInput(assets_list_only_output);

    const assets_mod = b.createModule(.{ .root_source_file = assets_zig_output });
    module.addImport(options.import_name, assets_mod);

    const install_assets = b.addInstallDirectory(.{
        .source_dir = assets_dir_output,
        .install_dir = .{ .prefix = {} },
        .install_subdir = "assets",
    });
    b.getInstallStep().dependOn(&install_assets.step);

    return assets_mod;
}
