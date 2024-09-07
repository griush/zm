const std = @import("std");
const zm = @import("zm");

const float_tolerance = std.math.floatEps(f32);

test {
    std.testing.refAllDeclsRecursive(zm);
}

test "easeInOutCubic" {
    try std.testing.expectEqual(0.0, zm.easeInOutCubic(@as(f32, 0.0)));
    try std.testing.expectEqual(1.0, zm.easeInOutCubic(@as(f32, 1.0)));
}

test "Vec initialization" {
    const v = zm.Vec2f{ 2, -1 };
    const v2 = zm.Vec3f{ 1.5, -2, 4.2 };

    try std.testing.expectApproxEqAbs(2, v[0], float_tolerance);
    try std.testing.expectApproxEqAbs(-1, v[1], float_tolerance);

    try std.testing.expectApproxEqAbs(1.5, v2[0], float_tolerance);
    try std.testing.expectApproxEqAbs(-2.0, v2[1], float_tolerance);
    try std.testing.expectApproxEqAbs(4.2, v2[2], float_tolerance);
}

test "vec arithmetic" {
    const v = zm.Vec2f{ 2, -1 };
    const v2 = zm.Vec2f{ 1.5, 4.5 };

    const sum = v + v2;
    const diff = v - v2;

    try std.testing.expectApproxEqAbs(3.5, sum[0], float_tolerance);
    try std.testing.expectApproxEqAbs(3.5, sum[1], float_tolerance);

    try std.testing.expectApproxEqAbs(0.5, diff[0], float_tolerance);
    try std.testing.expectApproxEqAbs(-5.5, diff[1], float_tolerance);
}

test "Vec2 scale" {
    const v = zm.Vec2f{ 2, -1 };
    const scaled = zm.vec.scale(v, 3);

    try std.testing.expectApproxEqAbs(6, scaled[0], float_tolerance);
    try std.testing.expectApproxEqAbs(-3, scaled[1], float_tolerance);
}

test "Vec length" {
    const v = zm.Vec2f{ 2, -1 };
    const len = zm.vec.len(v);
    const square_len = zm.vec.lenSq(v);

    try std.testing.expectApproxEqAbs(@sqrt(5.0), len, float_tolerance);
    try std.testing.expectApproxEqAbs(5.0, square_len, float_tolerance);
}

test "Vec dot" {
    const v = zm.Vec3f{ 1, 2, 3 };
    const v2 = zm.Vec3f{ 4, 5, 6 };

    const dot = zm.vec.dot(v, v2);
    try std.testing.expectApproxEqAbs(32.0, dot, float_tolerance);
}

test "Vec normalize" {
    const a = zm.Vec3f{ 3, 4, 0 };
    try std.testing.expectEqual(@Vector(3, f32){ 0.6, 0.8, 0 }, zm.vec.normalize(a));
}

test "Vec3 cross" {
    const v1 = zm.vec.up(f32);
    const v2 = zm.vec.right(f32);

    try std.testing.expectEqual(zm.vec.forward(f32), zm.vec.cross(v2, v1));
}

test "Vec distance" {
    const origin = zm.vec.zero(3, f32);
    const up = zm.vec.up(f32);

    try std.testing.expectEqual(1.0, zm.vec.distance(origin, up));
}

test "Vec angle" {
    const right = zm.vec.right(f32);
    const up = zm.vec.up(f32);

    try std.testing.expectApproxEqAbs(zm.toRadians(90.0), zm.vec.angle(right, up), float_tolerance);
}

test "Vec angle with len 0" {
    const zero = zm.vec.zero(3, f32);
    const up = zm.vec.up(f32);

    try std.testing.expect(std.math.isNan(zm.vec.angle(zero, up)));
}

test "Vec2 lerp" {
    const a = zm.Vec2f{ 1.0, 2.0 };
    const b = zm.Vec2f{ 4.0, 6.0 };

    try std.testing.expectEqual(zm.Vec2f{ 1.0, 2.0 }, zm.vec.lerp(a, b, 0.0));
    try std.testing.expectEqual(zm.Vec2f{ 4.0, 6.0 }, zm.vec.lerp(a, b, 1.0));
    try std.testing.expectEqual(zm.Vec2f{ 2.5, 4.0 }, zm.vec.lerp(a, b, 0.5));
    try std.testing.expectEqual(zm.Vec2f{ 1.75, 3.0 }, zm.vec.lerp(a, b, 0.25));
    try std.testing.expectEqual(zm.Vec2f{ 3.25, 5.0 }, zm.vec.lerp(a, b, 0.75));
}

test "vector reflect along self" {
    const v = zm.Vec2f{ 1, 0 };
    const n = zm.Vec2f{ 1, 0 };
    const expected = zm.Vec2f{ -1, 0 };

    try std.testing.expectEqual(expected, zm.vec.reflect(v, n));
}

test "vector reflect along y" {
    const v = zm.Vec2f{ 1, 1 };
    const n = zm.Vec2f{ 0, 1 };
    const expected = zm.Vec2f{ 1, -1 };

    try std.testing.expectEqual(expected, zm.vec.reflect(v, n));
}

test "vector reflect along x" {
    const v = zm.Vec2f{ 1, 1 };
    const n = zm.Vec2f{ 1, 0 };
    const expected = zm.Vec2f{ -1, 1 };

    try std.testing.expectEqual(expected, zm.vec.reflect(v, n));
}

test "vector reflect 3d" {
    const v = zm.Vec3f{ 1, 2, 3 };
    const n = zm.Vec3f{ 0, 0, 1 };
    const expected = zm.Vec3f{ 1, 2, -3 };

    try std.testing.expectEqual(expected, zm.vec.reflect(v, n));
}

test "Mat2 scale" {
    const m = zm.Mat2f.scaling(1.0, 2.0);
    const v = zm.Vec2f{ 3, 1.5 };

    try std.testing.expectEqual(zm.Vec2f{ 3, 3 }, m.multiplyVec2(v));
}

test "Mat3 scale" {
    const result = zm.Mat3f.identity().scale(3.0);
    try std.testing.expectEqual(zm.Mat3f.diagonal(3.0).data, result.data);
}

test "Mat4 scale" {
    const result = zm.Mat4f.identity().scale(3.0);
    try std.testing.expectEqual(zm.Mat4f.diagonal(3.0).data, result.data);
}

test "Mat4 multiply" {
    const m1 = zm.Mat4f{
        .data = .{
            1, 2, 2, 2,
            2, 3, 2, 1,
            2, 2, 1, 4,
            1, 1, 1, 1,
        },
    };

    const m2 = zm.Mat4f{
        .data = .{
            -1,   0,     0,    2,
            0.25, 0.75,  0.25, -2.25,
            0.5,  -0.5,  -0.5, 1.5,
            0.25, -0.25, 0.25, -0.25,
        },
    };

    const m: zm.Mat4f = zm.Mat4f.multiply(m1, m2);

    try std.testing.expectEqual(zm.Mat4f.identity().data, m.data);
}

test "Mat4 inverse" {
    const m1 = zm.Mat4f{
        .data = .{
            1, 2, 2, 2,
            2, 3, 2, 1,
            2, 2, 1, 4,
            1, 1, 1, 1,
        },
    };

    const m2 = zm.Mat4f{
        .data = .{
            -1,   0,     0,    2,
            0.25, 0.75,  0.25, -2.25,
            0.5,  -0.5,  -0.5, 1.5,
            0.25, -0.25, 0.25, -0.25,
        },
    };

    const m: zm.Mat4f = zm.Mat4f.inverse(m1);

    try std.testing.expectEqual(m2.data, m.data);
}

test "clamp" {
    try std.testing.expectEqual(0.0, zm.clamp(0.0, -1.0, 1.0));
    try std.testing.expectEqual(2.0, zm.clamp(3.0, 1.0, 2.0));
    try std.testing.expectEqual(4.0, zm.clamp(3.0, 4.0, 8.0));
}

test "Mat2 multiply Vec2" {
    const transform = zm.Mat2f.rotation(-std.math.pi / 2.0);
    const vec = zm.Vec2f{ 0.0, 1.0 };

    const rotated = transform.multiplyVec2(vec);

    try std.testing.expectApproxEqAbs(1.0, rotated[0], float_tolerance);
    try std.testing.expectApproxEqAbs(0.0, rotated[1], float_tolerance);
}

test "Quaternion multiply" {
    const i = zm.Quaternionf.identity();
    const a = zm.Quaternionf.init(1, 1, 1, 1);

    try std.testing.expectEqual(zm.Quaternionf.init(1, 1, 1, 1), a.multiply(i));
    try std.testing.expectEqual(zm.Quaternionf.init(-2, 2, 2, 2), a.multiply(a));
}

test "Quaternion conjugate" {
    const q = zm.Quaternionf.init(1, 1, 1, 1);
    const q_c = q.conjugate();

    try std.testing.expectEqual(zm.Quaternionf.init(1, -1, -1, -1), q_c);
}

test "Quaternion inverse" {
    const q = zm.Quaternionf.init(1, 1, 1, 1);
    const q_i = q.inverse();

    try std.testing.expectEqual(zm.Quaternionf.init(0.25, -0.25, -0.25, -0.25), q_i);
}

test "Quaternion slerp" {
    const a = zm.Quaternionf.identity();
    const b = zm.Quaternionf.fromAxisAngle(zm.vec.up(f32), std.math.pi);
    const qs = zm.Quaternionf.slerp(a, b, 1.0);

    // The test should not pass as the expected is different init
    // the result, however
    // this two values represent the same orientations, so it's a scrifice for the performance
    // not having the same value, but in practice, nothing changes
    const expected = zm.Quaternionf.init(0, 0, -1, 0);

    try std.testing.expectApproxEqAbs(expected.w, qs.w, float_tolerance);
    try std.testing.expectApproxEqAbs(expected.x, qs.x, float_tolerance);
    try std.testing.expectApproxEqAbs(expected.y, qs.y, float_tolerance);
    try std.testing.expectApproxEqAbs(expected.z, qs.z, float_tolerance);

    const c = zm.Quaternionf.slerp(a, b, 0.5);
    var d = zm.Quaternionf.init(0.7071067811865475, 0, -0.7071067811865475, 0);
    d.normalize();

    try std.testing.expectApproxEqAbs(d.w, c.w, float_tolerance);
    try std.testing.expectApproxEqAbs(d.x, c.x, float_tolerance);
    try std.testing.expectApproxEqAbs(d.y, c.y, float_tolerance);
    try std.testing.expectApproxEqAbs(d.z, c.z, float_tolerance);
}

test "Quaternion to Mat4" {
    const q = zm.Quaternionf.init(0.7071067811865475, 0.7071067811865475, 0.0, 0.0);
    const m = zm.Mat4f.fromQuaternion(q);

    const expected = zm.Mat4f{
        .data = .{
            1, 0, 0,  0,
            0, 0, -1, 0,
            0, 1, 0,  0,
            0, 0, 0,  1,
        },
    };

    for (0..16) |i| {
        try std.testing.expectApproxEqAbs(expected.data[i], m.data[i], float_tolerance);
    }
}

test "Ray" {
    const ray = zm.Rayf.init(zm.vec.zero(3, f32), zm.vec.right(f32));
    const expect = zm.vec.right(f32);

    try std.testing.expectEqual(expect, ray.at(1.0));
    try std.testing.expectEqual(zm.vec.zero(3, f32), ray.at(0.0));
}

test "AABB intersect" {
    const a = zm.AABB.init(zm.vec.zero(3, f32), zm.Vec3f{ 1, 1, 1 });
    const b = zm.AABB.init(zm.vec.zero(3, f32), zm.Vec3f{ 2, 2, 2 });

    try std.testing.expect(a.intersects(b));
}

test "AABB contains" {
    const a = zm.AABB.init(zm.vec.zero(3, f32), zm.Vec3f{ 1, 1, 1 });
    const p = zm.Vec3f{ 0.5, 0.5, 0.5 };
    try std.testing.expect(a.containsPoint(p));
}
