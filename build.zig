const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const root_source_file = b.path("src/root.zig");

    // Zig module
    const zm = b.addModule("root", .{
        .root_source_file = root_source_file,
    });

    // Library
    const lib = b.addStaticLibrary(.{
        .name = "zm",
        .root_source_file = root_source_file,
        .target = target,
        .optimize = optimize,
    });

    // Tests step
    const test_step = b.step("test", "Run zm tests");
    const tests = b.addTest(.{
        .name = "zm-tests",
        .root_source_file = b.path("src/tests.zig"),
        .target = target,
        .optimize = optimize,
    });

    tests.root_module.addImport("zm", zm);

    b.installArtifact(tests);
    test_step.dependOn(&b.addRunArtifact(tests).step);

    // Docs step
    const install_docs = b.addInstallDirectory(.{
        .source_dir = lib.getEmittedDocs(),
        .install_dir = .{ .custom = "." },
        .install_subdir = "docs",
    });

    const docs_step = b.step("docs", "Emit documentation");
    docs_step.dependOn(&install_docs.step);
}
