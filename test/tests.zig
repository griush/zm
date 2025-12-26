const std = @import("std");
const testing = std.testing;

const float_tolerance = std.math.floatEps(f32);

const zm = @import("zm");

test "dot product with orthogonal vectors is zero" {
    const expectApproxEqAbs = std.testing.expectApproxEqAbs;

    const a = zm.Vec2{ .data = .{1.0, 0.0} };
    const b = zm.Vec2{ .data = .{0.0, 42.0} };

    try expectApproxEqAbs(0.0, a.dot(b), float_tolerance);
}

test "norm produces unit vector" {
    const v = zm.Vec3{ .data = .{3.0, 4.0, 0.0} };
    const n = v.norm();

    // length of normalized vector should be 1
    try testing.expectApproxEqAbs(1.0, n.len(), float_tolerance);

    // normalized vector should point in same direction (dot product > 0)
    try testing.expect(n.dot(v) > 0);
}

test "distance is symmetric and consistent with len" {
    const a = zm.Vec3{ .data = .{1.0, 2.0, 3.0} };
    const b = zm.Vec3{ .data = .{4.0, 6.0, 3.0} };

    const d1 = a.distance(b);
    const d2 = b.distance(a);

    // symmetry
    try testing.expectApproxEqAbs(d1, d2, float_tolerance);

    // distance from a to itself is zero
    try testing.expectApproxEqAbs(0.0, a.distance(a), float_tolerance);

    // distance should match len(b - a)
    const diff = b.sub(a);
    try testing.expectApproxEqAbs(diff.len(), d1, float_tolerance);
}

test "lerp between two vectors" {
    const expectApproxEqAbs = testing.expectApproxEqAbs;

    const a = zm.Vec2{ .data = .{0.0, 0.0} };
    const b = zm.Vec2{ .data = .{10.0, 20.0} };

    const mid = a.lerp(b, 0.5);
    try expectApproxEqAbs(5.0, mid.data[0], float_tolerance);
    try expectApproxEqAbs(10.0, mid.data[1], float_tolerance);

    // extrapolation: t = 2 should go past b
    const extra = a.lerp(b, 2.0);
    try expectApproxEqAbs(20.0, extra.data[0], float_tolerance);
    try expectApproxEqAbs(40.0, extra.data[1], float_tolerance);
}

test "reflect across axis" {
    const expectApproxEqAbs = testing.expectApproxEqAbs;

    // reflect (1, -1) across y-axis normal (1,0)
    const v1 = zm.Vec2{ .data = .{1.0, -1.0} };
    const v2 = zm.Vec2{ .data = .{1.0, 0.0} };
    const normal = v2.norm();

    const reflected = v1.reflect(normal);
    try expectApproxEqAbs(-1.0, reflected.data[0], float_tolerance);
    try expectApproxEqAbs(-1.0, reflected.data[1], float_tolerance);
}

test "angle between orthogonal and parallel vectors" {
    const expectApproxEqAbs = testing.expectApproxEqAbs;
    const pi = std.math.pi;

    const x = zm.Vec2{ .data = .{1.0, 0.0} };
    const y = zm.Vec2{ .data = .{0.0, 1.0} };

    // 90 degrees between x and y
    const angle_xy = zm.Vec2.angle(x, y);
    try expectApproxEqAbs(pi / 2.0, angle_xy, float_tolerance);

    // 0 degrees between x and itself
    const angle_xx = zm.Vec2.angle(x, x);
    try expectApproxEqAbs(0.0, angle_xx, float_tolerance);
}

test "crossRH and crossLH basic correctness" {
    const v1 = zm.Vec3{ .data = .{1.0, 0.0, 0.0} }; // x-axis
    const v2 = zm.Vec3{ .data = .{0.0, 1.0, 0.0} }; // y-axis

    const rh = v1.crossRH(v2);
    const lh = v1.crossLH(v2);

    // RH rule: x × y = z
    try testing.expectApproxEqAbs(0.0, rh.data[0], float_tolerance);
    try testing.expectApproxEqAbs(0.0, rh.data[1], float_tolerance);
    try testing.expectApproxEqAbs(1.0, rh.data[2], float_tolerance);

    // LH should be the negative
    try testing.expectApproxEqAbs(-rh.data[0], lh.data[0], float_tolerance);
    try testing.expectApproxEqAbs(-rh.data[1], lh.data[1], float_tolerance);
    try testing.expectApproxEqAbs(-rh.data[2], lh.data[2], float_tolerance);

    // orthogonality check
    const dot1 = rh.dot(v1);
    const dot2 = rh.dot(v2);
    try testing.expectApproxEqAbs(0.0, dot1, float_tolerance);
    try testing.expectApproxEqAbs(0.0, dot2, float_tolerance);
}

test "crossRH and crossLH other ordering" {

    const v1 = zm.Vec3{ .data = .{0.0, 1.0, 0.0} }; // y-axis
    const v2 = zm.Vec3{ .data = .{0.0, 0.0, 1.0} }; // z-axis

    const rh = v1.crossRH(v2);
    const lh = v1.crossLH(v2);

    // RH: y × z = x
    try testing.expectApproxEqAbs(1.0, rh.data[0], float_tolerance);
    try testing.expectApproxEqAbs(0.0, rh.data[1], float_tolerance);
    try testing.expectApproxEqAbs(0.0, rh.data[2], float_tolerance);

    // LH is opposite
    try testing.expectApproxEqAbs(-1.0, lh.data[0], float_tolerance);
    try testing.expectApproxEqAbs(0.0, lh.data[1], float_tolerance);
    try testing.expectApproxEqAbs(0.0, lh.data[2], float_tolerance);
}

test "cross product with parallel vectors is zero" {
    const expectApproxEqAbs = std.testing.expectApproxEqAbs;

    const a = zm.Vec3{ .data = .{1.0, 2.0, 3.0} };
    const b = a.scale(5.0); // parallel to a

    const rh = a.crossRH(b);
    try expectApproxEqAbs(0.0, rh.data[0], float_tolerance);
    try expectApproxEqAbs(0.0, rh.data[1], float_tolerance);
    try expectApproxEqAbs(0.0, rh.data[2], float_tolerance);
}

test "fromAxisAngleRH 90deg about X" {
    const expectApproxEqAbs = std.testing.expectApproxEqAbs;
    const pi = std.math.pi;

    const axis = zm.Vec3{ .data = .{1.0, 0.0, 0.0} };
    const q = zm.Quaternion(f64).fromAxisAngleRH(axis, pi / 2.0);

    // Should represent cos(θ/2) + x·sin(θ/2)
    try expectApproxEqAbs(std.math.cos(pi / 4.0), q.w, float_tolerance);
    try expectApproxEqAbs(std.math.sin(pi / 4.0), q.x, float_tolerance);
    try expectApproxEqAbs(0.0, q.y, float_tolerance);
    try expectApproxEqAbs(0.0, q.z, float_tolerance);
}

test "fromAxisAngleLH is negation of RH" {
    const expectApproxEqAbs = std.testing.expectApproxEqAbs;
    const pi = std.math.pi;

    const axis = zm.Vec3{ .data = .{0.0, 1.0, 0.0} };
    const q_rh = zm.Quaternion(f64).fromAxisAngleRH(axis, pi / 3.0);
    const q_lh = zm.Quaternion(f64).fromAxisAngleLH(axis, pi / 3.0);

    try expectApproxEqAbs(q_rh.w, q_lh.w, float_tolerance);
    try expectApproxEqAbs(q_rh.x, -q_lh.x, float_tolerance);
    try expectApproxEqAbs(q_rh.y, -q_lh.y, float_tolerance);
    try expectApproxEqAbs(q_rh.z, -q_lh.z, float_tolerance);
}

test "fromEulerAnglesRH xyz order matches axis-angle composition" {
    const expectApproxEqAbs = std.testing.expectApproxEqAbs;
    const pi = std.math.pi;

    const euler = zm.Vec3{ .data = .{pi / 2.0, 0.0, 0.0} };
    const q_euler = zm.Quaternion(f64).fromEulerAnglesRH(euler, .xyz, .intrinsic);

    const axis = zm.Vec3{ .data = .{1.0, 0.0, 0.0} };
    const q_axis = zm.Quaternion(f64).fromAxisAngleRH(axis, pi / 2.0);

    try expectApproxEqAbs(q_axis.w, q_euler.w, float_tolerance);
    try expectApproxEqAbs(q_axis.x, q_euler.x, float_tolerance);
    try expectApproxEqAbs(q_axis.y, q_euler.y, float_tolerance);
    try expectApproxEqAbs(q_axis.z, q_euler.z, float_tolerance);
}

test "fromMat3 identity matrix gives identity quaternion" {
    const expectApproxEqAbs = std.testing.expectApproxEqAbs;
    const i = zm.Mat(3,3,f64).identity();

    const q = zm.Quaternion(f64).fromMat3(i);
    try expectApproxEqAbs(1.0, q.w, float_tolerance);
    try expectApproxEqAbs(0.0, q.x, float_tolerance);
    try expectApproxEqAbs(0.0, q.y, float_tolerance);
    try expectApproxEqAbs(0.0, q.z, float_tolerance);
}

test "fromMat4 rotation about Z matches axis-angle" {
    const expectApproxEqAbs = std.testing.expectApproxEqAbs;
    const pi = std.math.pi;

    // Rotation 90deg about Z
    var r = zm.Mat(4, 4, f64).identity();
    r.data[0][0] = 0.0;
    r.data[0][1] = -1.0;
    r.data[1][0] = 1.0;
    r.data[1][1] = 0.0;

    const q_mat = zm.Quaternion(f64).fromMat4(r);

    const axis = zm.Vec3{ .data = .{0.0, 0.0, 1.0} };
    const q_axis = zm.Quaternion(f64).fromAxisAngleRH(axis, pi / 2.0);

    try expectApproxEqAbs(q_axis.w, q_mat.w, float_tolerance);
    try expectApproxEqAbs(q_axis.x, q_mat.x, float_tolerance);
    try expectApproxEqAbs(q_axis.y, q_mat.y, float_tolerance);
    try expectApproxEqAbs(q_axis.z, q_mat.z, float_tolerance);
}

test "Ray.at returns origin when t = 0" {
    const expectApproxEqAbs = std.testing.expectApproxEqAbs;

    const origin = zm.Vec3{ .data = .{1.0, 2.0, 3.0} };
    const dir = zm.Vec3{ .data = .{0.0, 1.0, 0.0} };

    const ray = zm.Rayd.init(origin, dir);

    const p = ray.at(0.0);
    try expectApproxEqAbs(1.0, p.data[0], float_tolerance);
    try expectApproxEqAbs(2.0, p.data[1], float_tolerance);
    try expectApproxEqAbs(3.0, p.data[2], float_tolerance);
}

test "Ray.at moves along direction for positive t" {
    const expectApproxEqAbs = std.testing.expectApproxEqAbs;

    const origin = zm.Vec3{ .data = .{0.0, 0.0, 0.0} };
    const dir = zm.Vec3{ .data = .{1.0, 2.0, 3.0} };

    const ray = zm.Rayd.init(origin, dir);

    const p = ray.at(2.0);
    try expectApproxEqAbs(2.0, p.data[0], float_tolerance);
    try expectApproxEqAbs(4.0, p.data[1], float_tolerance);
    try expectApproxEqAbs(6.0, p.data[2], float_tolerance);
}

test "Ray.at handles negative t (extends backwards)" {
    const expectApproxEqAbs = std.testing.expectApproxEqAbs;

    const origin = zm.Vec3{ .data = .{5.0, 5.0, 5.0} };
    const dir = zm.Vec3{ .data = .{1.0, 0.0, 0.0} };

    const ray = zm.Rayd.init(origin, dir);

    const p = ray.at(-3.0);
    try expectApproxEqAbs(2.0, p.data[0], float_tolerance);
    try expectApproxEqAbs(5.0, p.data[1], float_tolerance);
    try expectApproxEqAbs(5.0, p.data[2], float_tolerance);
}

test "Matrix3 multiplication" {
    const expectApproxEqAbs = std.testing.expectApproxEqAbs;

    const mat_a = zm.Mat(3, 3, f32){ .data = .{
        .{ 1.0, 2.0, 3.0 },
        .{ 4.0, 5.0, 6.0 },
        .{ 7.0, 8.0, 9.0 },
    } };
    const mat_b = zm.Mat(3, 3, f32){ .data = .{
        .{ 9.0, 8.0, 7.0 },
        .{ 6.0, 5.0, 4.0 },
        .{ 3.0, 2.0, 1.0 },
    } };

    const result = mat_a.multiply(mat_b);
    const expected = zm.Mat(3, 3, f32){ .data = .{
        .{ 30.0, 24.0, 18.0 },
        .{ 84.0, 69.0, 54.0 },
        .{ 138.0, 114.0, 90.0 },
    } };

    for (0..@TypeOf(expected).rows()) |i| {
        for (0..@TypeOf(expected).cols()) |j| {
            try expectApproxEqAbs(expected.data[i][j], result.data[i][j], float_tolerance);
        }
    }
}

test "Matrix4 multiplication" {
    const expectApproxEqAbs = std.testing.expectApproxEqAbs;

    const mat_a = zm.Mat(4, 4, f32){ .data = .{
        .{ 1.0, 2.0, 3.0, 4.0 },
        .{ 5.0, 6.0, 7.0, 8.0 },
        .{ 9.0, 10.0, 11.0, 12.0 },
        .{ 13.0, 14.0, 15.0, 16.0 },
    } };
    const mat_b = zm.Mat(4, 4, f32){ .data = .{
        .{ 16.0, 15.0, 14.0, 13.0 },
        .{ 12.0, 11.0, 10.0, 9.0 },
        .{ 8.0, 7.0, 6.0, 5.0 },
        .{ 4.0, 3.0, 2.0, 1.0 },
    } };

    const result = mat_a.multiply(mat_b);
    const expected = zm.Mat(4, 4, f32){ .data = .{
        .{ 80.0, 70.0, 60.0, 50.0 },
        .{ 240.0, 214.0, 188.0, 162.0 },
        .{ 400.0, 358.0, 316.0, 274.0 },
        .{ 560.0, 502.0, 444.0, 386.0 },
    } };

    for (0..@TypeOf(expected).rows()) |i| {
        for (0..@TypeOf(expected).cols()) |j| {
            try expectApproxEqAbs(expected.data[i][j], result.data[i][j], float_tolerance);
        }
    }
}
