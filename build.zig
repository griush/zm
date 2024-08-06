const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const root_source_file = b.path("src/root.zig");

    // Zig module
    const zm = b.addModule("zm", .{
        .root_source_file = root_source_file,
    });

    // Library
    const lib = b.addStaticLibrary(.{
        .name = "zm",
        .root_source_file = root_source_file,
        .target = target,
        .optimize = optimize,
    });

    // Check step to see if it compiles
    const check = b.step("check", "Check if foo compiles");
    check.dependOn(&lib.step);

    // Tests step
    const test_step = b.step("test", "Run zm tests");
    const tests = b.addTest(.{
        .name = "zm-tests",
        .root_source_file = b.path("test/tests.zig"),
        .target = target,
        .optimize = optimize,
    });

    tests.root_module.addImport("zm", zm);

    b.installArtifact(tests);
    test_step.dependOn(&b.addRunArtifact(tests).step);

    // Benchmark step
    const benchmark_step = b.step("benchmark", "Run zm benchmark");
    const benchmark = b.addExecutable(.{
        .name = "zm-benchmark",
        .root_source_file = b.path("test/benchmark.zig"),
        .target = target,
        .optimize = optimize,
    });

    benchmark.root_module.addImport("zm", zm);

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
