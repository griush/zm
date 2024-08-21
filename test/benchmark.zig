const std = @import("std");
const zm = @import("zm");

var prng = std.Random.Pcg.init(0);
const random = prng.random();

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const g_allocator = gpa.allocator();

pub fn main() !void {
    std.debug.print("zm - Benchmarks\n", .{});

    std.debug.print("Generating random data...\n", .{});
    const count = 1_000_000;
    var timer = try std.time.Timer.start();
    var vec2s = try std.ArrayList(zm.Vec2).initCapacity(g_allocator, count);
    var vec3s = try std.ArrayList(zm.Vec3).initCapacity(g_allocator, count);
    var vec4s = try std.ArrayList(zm.Vec4).initCapacity(g_allocator, count);
    var quaternions = try std.ArrayList(zm.Quaternion).initCapacity(g_allocator, count);
    for (0..count) |_| {
        try vec2s.append(zm.Vec2.from(random.float(f32), random.float(f32)));
        try vec3s.append(zm.Vec3.from(random.float(f32), random.float(f32), random.float(f32)));
        try vec4s.append(zm.Vec4.from(random.float(f32), random.float(f32), random.float(f32), random.float(f32)));
        try quaternions.append(zm.Quaternion.from(random.float(f32), random.float(f32), random.float(f32), random.float(f32)));
    }

    std.debug.print("Done, took: {d}ms\n", .{@as(f64, @floatFromInt(timer.lap())) / 1_000_000.0});
    timer.reset();

    // vec2 add
    for (0..count - 1) |i| {
        const a = vec2s.items[i];
        const b = vec2s.items[i + 1];

        const c = a.add(b);

        std.mem.doNotOptimizeAway(c);
    }

    std.debug.print("Test - Vec2 add({}): {d} ms\n", .{ count, @as(f64, @floatFromInt(timer.lap())) / 1_000_000.0 });
    timer.reset();

    // vec3 add
    for (0..count - 1) |i| {
        const a = vec3s.items[i];
        const b = vec3s.items[i + 1];

        const c = a.add(b);

        std.mem.doNotOptimizeAway(c);
    }

    std.debug.print("Test - Vec3 add({}): {d} ms\n", .{ count, @as(f64, @floatFromInt(timer.lap())) / 1_000_000.0 });
    timer.reset();

    // vec4 add
    for (0..count - 1) |i| {
        const a = vec4s.items[i];
        const b = vec4s.items[i + 1];

        const c = a.add(b);

        std.mem.doNotOptimizeAway(c);
    }

    std.debug.print("Test - Vec4 add({}): {d} ms\n", .{ count, @as(f64, @floatFromInt(timer.lap())) / 1_000_000.0 });
    timer.reset();

    // vec3 dot product
    for (0..count - 1) |i| {
        const a = vec3s.items[i];
        const b = vec3s.items[i + 1];

        const c = a.dot(b);

        std.mem.doNotOptimizeAway(c);
    }

    std.debug.print("Test - Vec3 dot({}): {d} ms\n", .{ count, @as(f64, @floatFromInt(timer.lap())) / 1_000_000.0 });
    timer.reset();

    // vec4 dot
    for (0..count - 1) |i| {
        const a = vec4s.items[i];
        const b = vec4s.items[i + 1];

        const c = a.dot(b);

        std.mem.doNotOptimizeAway(c);
    }

    std.debug.print("Test - Vec4 dot({}): {d} ms\n", .{ count, @as(f64, @floatFromInt(timer.lap())) / 1_000_000.0 });
    timer.reset();

    // Normalize
    for (0..count) |i| {
        const v = vec3s.items[i].normalized();
        std.mem.doNotOptimizeAway(v);
    }

    std.debug.print("Test - Vec3 Normalize({}): {d} ms\n", .{ count, @as(f64, @floatFromInt(timer.lap())) / 1_000_000.0 });
    timer.reset();

    // Length
    for (0..count) |i| {
        const length = vec3s.items[i].len();
        std.mem.doNotOptimizeAway(length);
    }

    std.debug.print("Test - Vec3 Length({}): {d} ms\n", .{ count, @as(f64, @floatFromInt(timer.lap())) / 1_000_000.0 });
    timer.reset();

    // Lerp
    for (0..count - 1) |i| {
        const a = vec3s.items[i];
        const b = vec3s.items[i + 1];

        const c = zm.Vec3.lerp(a, b, 0.5);

        std.mem.doNotOptimizeAway(c);
    }

    std.debug.print("Test - Vec3 Lerp({}): {d} ms\n", .{ count, @as(f64, @floatFromInt(timer.lap())) / 1_000_000.0 });
    timer.reset();

    // Cross + scale
    for (0..count - 1) |i| {
        const a = vec3s.items[i];
        const b = vec3s.items[i + 1];

        const c = a.cross(b).scale(2.0);

        std.mem.doNotOptimizeAway(c);
    }

    std.debug.print("Test - Vec3 Cross + Vec3 scale({}): {d} ms\n", .{ count, @as(f64, @floatFromInt(timer.lap())) / 1_000_000.0 });
    timer.reset();

    // TODO: bring back angle
    // // angle
    // for (0..count - 1) |i| {
    //     const a = vec3s.items[i];
    //     const b = vec3s.items[i + 1];
    //
    //     const c = a.angle(b);
    //     std.mem.doNotOptimizeAway(c);
    // }
    //
    // std.debug.print("Test - Vec3 angle({}): {d} ms\n", .{ count, @as(f64, @floatFromInt(timer.lap())) / 1_000_000.0 });

    // mat mul vec
    for (0..count) |i| {
        const m = zm.Mat4.perspective(std.math.pi / 2.0, 16.0 / 9.0, 0.05, 100.0);
        const v = vec4s.items[i];
        const r = zm.Mat4.multiplyVec4(m, v);

        std.mem.doNotOptimizeAway(r);
    }

    std.debug.print("Test - Mat4 multiply Vec4({}): {d} ms\n", .{ count, @as(f64, @floatFromInt(timer.lap())) / 1_000_000.0 });
    timer.reset();

    // create translation + transpose
    for (0..count) |i| {
        const m = zm.Mat4.translation(0, @floatFromInt(i), 0);
        const t = m.transpose();
        std.mem.doNotOptimizeAway(t);
    }

    std.debug.print("Test - Mat4 translation + transpose({}): {d} ms\n", .{ count, @as(f64, @floatFromInt(timer.lap())) / 1_000_000.0 });
    timer.reset();

    // create translation + inverse
    for (0..count) |i| {
        const m = zm.Mat4.translation(0, @floatFromInt(i), 0);
        const t = m.inverse();
        std.mem.doNotOptimizeAway(t);
    }

    std.debug.print("Test - Mat4 translation + inverse({}): {d} ms\n", .{ count, @as(f64, @floatFromInt(timer.lap())) / 1_000_000.0 });
    timer.reset();

    // quaternion slerp
    for (0..count - 1) |i| {
        const a = quaternions.items[i];
        const b = quaternions.items[i + 1];
        const t = zm.Quaternion.slerp(a, b, 0.5);
        std.mem.doNotOptimizeAway(t);
    }

    std.debug.print("Test - Quaternion slerp({}): {d} ms\n", .{ count, @as(f64, @floatFromInt(timer.lap())) / 1_000_000.0 });
    timer.reset();
}
