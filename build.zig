const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const root_source_file = b.path("src/zm.zig");

    // zm lib module
    const zm = b.addModule("zm", .{
        .root_source_file = root_source_file,
        .target = target,
        .optimize = optimize,
    });

    // library
    const lib = b.addStaticLibrary(.{
        .name = "zm",
        .root_module = zm,
    });

    // check step to see if the zm compiles
    const check = b.step("check", "Check if zm compiles");
    check.dependOn(&lib.step);

    // tests step
    const zm_tests = b.createModule(.{
        .root_source_file = b.path("test/tests.zig"),
        .target = target,
        .optimize = optimize,
    });
    zm_tests.addImport("zm", zm);

    const test_step = b.step("test", "Run zm tests");
    const tests = b.addTest(.{
        .name = "zm-tests",
        .root_module = zm_tests,
    });

    b.installArtifact(tests);
    test_step.dependOn(&b.addRunArtifact(tests).step);

    // benchmark step
    const zm_benchmark = b.createModule(.{
        .root_source_file = b.path("test/benchmark.zig"),
        .target = target,
        .optimize = .ReleaseFast,
    });

    zm_benchmark.addImport("zm", zm);

    const benchmark_step = b.step("benchmark", "Run zm benchmark");
    const benchmark = b.addExecutable(.{
        .name = "zm-benchmark",
        .root_module = zm_benchmark,
        .optimize = .ReleaseFast,
    });
    b.installArtifact(benchmark);
    benchmark_step.dependOn(&b.addRunArtifact(benchmark).step);

    // Docs step
    const install_docs = b.addInstallDirectory(.{
        .source_dir = lib.getEmittedDocs(),
        .install_dir = .{ .custom = "." },
        .install_subdir = "docs",
    });

    const docs_step = b.step("docs", "Emit documentation");
    docs_step.dependOn(&install_docs.step);
}
