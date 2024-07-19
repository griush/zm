const std = @import("std");
const zm = @import("zm");

const float_tolerance = std.math.floatEps(f32);

test "Vec initialization" {
    const v = zm.Vec2.from(2, -1);
    const v2 = zm.Vec3.from(1.5, -2, 4.2);

    try std.testing.expectApproxEqAbs(2, v.x(), float_tolerance);
    try std.testing.expectApproxEqAbs(-1, v.y(), float_tolerance);

    try std.testing.expectApproxEqAbs(1.5, v2.x(), float_tolerance);
    try std.testing.expectApproxEqAbs(-2.0, v2.y(), float_tolerance);
    try std.testing.expectApproxEqAbs(4.2, v2.z(), float_tolerance);
}

test "vec arithmetic" {
    const v = zm.Vec2.from(2, -1);
    const v2 = zm.Vec2.from(1.5, 4.5);

    const sum = zm.Vec2.add(v, v2);
    const diff = zm.Vec2.add(v, v2.neg());

    try std.testing.expectApproxEqAbs(3.5, sum.x(), float_tolerance);
    try std.testing.expectApproxEqAbs(3.5, sum.y(), float_tolerance);

    try std.testing.expectApproxEqAbs(0.5, diff.x(), float_tolerance);
    try std.testing.expectApproxEqAbs(-5.5, diff.y(), float_tolerance);
}

test "Vec2 scale" {
    var v = zm.Vec2.from(2, -1);

    v.scale(3.0);

    try std.testing.expectApproxEqAbs(6, v.x(), float_tolerance);
    try std.testing.expectApproxEqAbs(-3, v.y(), float_tolerance);
}

test "Vec length" {
    const v = zm.Vec2.from(2, -1);
    const len = v.length();
    const square_len = v.squareLength();

    try std.testing.expectApproxEqAbs(@sqrt(5.0), len, float_tolerance);
    try std.testing.expectApproxEqAbs(5.0, square_len, float_tolerance);
}

test "Vec dot" {
    const v = zm.Vec3.from(1, 2, 3);
    const v2 = zm.Vec3.from(4, 5, 6);

    const dot = zm.Vec3.dot(v, v2);

    try std.testing.expectApproxEqAbs(32.0, dot, float_tolerance);
}

test "Vec normalize" {
    var x = zm.Vec3.from(1, 0, 0);
    var y = zm.Vec3.from(0, 1, 0);
    var z = zm.Vec3.from(0, 0, 1);

    x.normalize();
    y.normalize();
    z.normalize();

    try std.testing.expectEqual(@Vector(3, f32){ 1, 0, 0 }, x.data);
    try std.testing.expectEqual(@Vector(3, f32){ 0, 1, 0 }, y.data);
    try std.testing.expectEqual(@Vector(3, f32){ 0, 0, 1 }, z.data);
}

test "Mat4 scale" {
    var identity = zm.Mat4.identity();
    identity.scale(3.0);

    try std.testing.expectEqual(zm.Mat4.diagonal(3.0).data, identity.data);
}

test "Mat4 multiply" {
    const m1 = zm.Mat4{
        .data = .{
            1, 2, 2, 2,
            2, 3, 2, 1,
            2, 2, 1, 4,
            1, 1, 1, 1,
        },
    };

    const m2 = zm.Mat4{
        .data = .{
            -1,   0,     0,    2,
            0.25, 0.75,  0.25, -2.25,
            0.5,  -0.5,  -0.5, 1.5,
            0.25, -0.25, 0.25, -0.25,
        },
    };

    const m: zm.Mat4 = zm.Mat4.multiply(m1, m2);

    try std.testing.expectEqual(zm.Mat4.identity().data, m.data);
}

test "Mat4 inverse" {
    const m1 = zm.Mat4{
        .data = .{
            1, 2, 2, 2,
            2, 3, 2, 1,
            2, 2, 1, 4,
            1, 1, 1, 1,
        },
    };

    const m2 = zm.Mat4{
        .data = .{
            -1,   0,     0,    2,
            0.25, 0.75,  0.25, -2.25,
            0.5,  -0.5,  -0.5, 1.5,
            0.25, -0.25, 0.25, -0.25,
        },
    };

    const m: zm.Mat4 = zm.Mat4.inverse(m1);

    try std.testing.expectEqual(m2.data, m.data);
}

test "clamp" {
    try std.testing.expectEqual(0.0, zm.clamp(0.0, -1.0, 1.0));
    try std.testing.expectEqual(2.0, zm.clamp(3.0, 1.0, 2.0));
    try std.testing.expectEqual(4.0, zm.clamp(3.0, 4.0, 8.0));
}

test "Vec2 lerp" {
    const a = zm.Vec2.from(1.0, 2.0);
    const b = zm.Vec2.from(4.0, 6.0);

    try std.testing.expectEqual(zm.Vec2.from(1.0, 2.0), zm.Vec2.lerp(a, b, 0.0));
    try std.testing.expectEqual(zm.Vec2.from(4.0, 6.0), zm.Vec2.lerp(a, b, 1.0));
    try std.testing.expectEqual(zm.Vec2.from(2.5, 4.0), zm.Vec2.lerp(a, b, 0.5));
    try std.testing.expectEqual(zm.Vec2.from(1.75, 3.0), zm.Vec2.lerp(a, b, 0.25));
    try std.testing.expectEqual(zm.Vec2.from(3.25, 5.0), zm.Vec2.lerp(a, b, 0.75));
}

test "Mat2 multiply Vec2" {
    const transform = zm.Mat2.rotation(-std.math.pi / 2.0);
    const vec = zm.Vec2.from(0.0, 1.0);

    const rotated = transform.multiplyVec2(vec);

    try std.testing.expectApproxEqAbs(1.0, rotated.x(), float_tolerance);
    try std.testing.expectApproxEqAbs(0.0, rotated.y(), float_tolerance);
}

test "print" {
    const v2 = zm.Vec2.from(1.0, 2.0);
    const v3 = zm.Vec3.from(1.0, 2.0, 3.0);
    const v4 = zm.Vec4.from(1.0, 2.0, 3.0, 4.0);
    const q = zm.Quaternion.identity();

    std.debug.print("2: {any}\n3: {any}\n4: {any}\n", .{ v2, v3, v4 });
    std.debug.print("q: {any}\n", .{q});
}

test "Quaternion multiply" {
    const i = zm.Quaternion.identity();
    const a = zm.Quaternion.from(1, 1, 1, 1);

    try std.testing.expectEqual(zm.Quaternion.from(1, 1, 1, 1), a.multiply(i));
    try std.testing.expectEqual(zm.Quaternion.from(-2, 2, 2, 2), a.multiply(a));
}

test "Quaternion conjugate" {
    const q = zm.Quaternion.from(1, 1, 1, 1);
    const q_c = q.conjugate();

    try std.testing.expectEqual(zm.Quaternion.from(1, -1, -1, -1), q_c);
}

test "Quaternion inverse" {
    const q = zm.Quaternion.from(1, 1, 1, 1);
    const q_i = q.inverse();

    try std.testing.expectEqual(zm.Quaternion.from(0.25, -0.25, -0.25, -0.25), q_i);
}

test "Quaternion slerp" {
    const a = zm.Quaternion.identity();
    const b = zm.Quaternion.fromAxisAngle(zm.Vec3.up(), std.math.pi);

    const qs = zm.Quaternion.slerp(a, b, 1.0);
    const expected = zm.Quaternion.from(0.0, 0, 1, 0);

    try std.testing.expectApproxEqAbs(expected.w, qs.w, float_tolerance);
    try std.testing.expectApproxEqAbs(expected.x, qs.x, float_tolerance);
    try std.testing.expectApproxEqAbs(expected.y, qs.y, float_tolerance);
    try std.testing.expectApproxEqAbs(expected.z, qs.z, float_tolerance);

    const c = zm.Quaternion.slerp(a, b, 0.5);
    var d = zm.Quaternion.from(0.7071067811865475, 0, 0.7071067811865475, 0);
    d.normalize();

    try std.testing.expectApproxEqAbs(c.w, d.w, float_tolerance);
    try std.testing.expectApproxEqAbs(c.x, d.x, float_tolerance);
    try std.testing.expectApproxEqAbs(c.y, d.y, float_tolerance);
    try std.testing.expectApproxEqAbs(c.z, d.z, float_tolerance);
}
