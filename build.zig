const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upb_zig = b.dependency("upb_runtime", .{
        .target = target,
        .optimize = optimize,
    });

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_mod.addImport("upb_zig", upb_zig.module("upb_zig"));

    const exe = b.addExecutable(.{
        .name = "example",
        .root_module = exe_mod,
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run the example");
    run_step.dependOn(&run_cmd.step);

    const dep_tests = b.addTest(.{
        .root_module = upb_zig.module("upb_zig"),
    });
    const run_dep_tests = b.addRunArtifact(dep_tests);
    const test_step = b.step("test", "Run dependency tests");
    test_step.dependOn(&run_dep_tests.step);
}
