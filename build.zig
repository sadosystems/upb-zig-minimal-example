const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upb_zig = b.dependency("upb_runtime", .{
        .target = target,
        .optimize = optimize,
    });
    const upb_mod = upb_zig.module("upb_zig");

    // Generated proto modules - each needs upb_zig, and example needs timestamp
    const timestamp_mod = b.createModule(.{
        .root_source_file = b.path("gen/google/protobuf/timestamp.pb.zig"),
        .target = target,
        .optimize = optimize,
    });
    timestamp_mod.addImport("upb_zig", upb_mod);

    const example_mod = b.createModule(.{
        .root_source_file = b.path("gen/proto/example/v1/example.pb.zig"),
        .target = target,
        .optimize = optimize,
    });
    example_mod.addImport("upb_zig", upb_mod);
    example_mod.addImport("google_protobuf_timestamp", timestamp_mod);

    // Executable
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_mod.addImport("upb_zig", upb_mod);
    exe_mod.addImport("example_pb", example_mod);
    exe_mod.addImport("google_protobuf_timestamp", timestamp_mod);

    const exe = b.addExecutable(.{
        .name = "example",
        .root_module = exe_mod,
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run the example");
    run_step.dependOn(&run_cmd.step);

    // Tests - run upb_zig dependency tests + our own
    const dep_tests = b.addTest(.{
        .root_module = upb_zig.module("upb_zig"),
    });
    const run_dep_tests = b.addRunArtifact(dep_tests);

    const test_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    test_mod.addImport("upb_zig", upb_mod);
    test_mod.addImport("example_pb", example_mod);

    const app_tests = b.addTest(.{
        .root_module = test_mod,
    });
    const run_app_tests = b.addRunArtifact(app_tests);

    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&run_dep_tests.step);
    test_step.dependOn(&run_app_tests.step);
}
