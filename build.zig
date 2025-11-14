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

    // library for docs
    const zm_lib = b.addLibrary(.{
        .linkage = .static,
        .name = "zm",
        .root_module = zm,
    });

    // tests step
    const test_step = b.step("test", "Run zm tests");
    const tests = b.addTest(.{
        .name = "zm-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("test/tests.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "zm", .module = zm },
            },
        }),
    });

    b.installArtifact(tests);
    test_step.dependOn(&b.addRunArtifact(tests).step);

    // benchmark step
    const benchmark_step = b.step("benchmark", "Run zm benchmark");
    const benchmark = b.addExecutable(.{
        .name = "zm-benchmark",
        .root_module = b.createModule(.{
            .root_source_file = b.path("test/benchmark.zig"),
            .target = target,
            .optimize = .ReleaseFast,
            .imports = &.{
                .{ .name = "zm", .module = zm },
            },
        }),
    });
    b.installArtifact(benchmark);
    benchmark_step.dependOn(&b.addRunArtifact(benchmark).step);

    // example step
    const example_step = b.step("example", "Run zm demo example");
    const example = b.addExecutable(.{
        .name = "zm-demo",
        .root_module = b.createModule(.{
            .root_source_file = b.path("examples/demo.zig"),
            .target = target,
            .imports = &.{
                .{ .name = "zm", .module = zm },
            },
        }),
    });
    b.installArtifact(example);
    example_step.dependOn(&b.addRunArtifact(example).step);

    // docs step
    const install_docs = b.addInstallDirectory(.{
        .source_dir = zm_lib.getEmittedDocs(),
        .install_dir = .{ .custom = "." },
        .install_subdir = "docs",
    });

    const docs_step = b.step("docs", "Emit documentation");
    docs_step.dependOn(&install_docs.step);
}
