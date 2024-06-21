const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const amth = b.addModule("root", .{
        .root_source_file = b.path("src/root.zig"),
    });

    const test_step = b.step("test", "Run arion-math tests");

    const tests = b.addTest(.{
        .name = "arion-math-tests",
        .root_source_file = b.path("src/tests.zig"),
        .target = target,
        .optimize = optimize,
    });

    tests.root_module.addImport("amth", amth);

    b.installArtifact(tests);

    test_step.dependOn(&b.addRunArtifact(tests).step);
}
