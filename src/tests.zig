const std = @import("std");
const amth = @import("amth");

test "Vec initialization" {
    const v = amth.Vec2.from(2, -1);
    const v2 = amth.Vec3.from(1.5, -2, 4.2);

    try std.testing.expectApproxEqAbs(2, v.x(), 0.0001);
    try std.testing.expectApproxEqAbs(-1, v.y(), 0.0001);

    try std.testing.expectApproxEqAbs(1.5, v2.x(), 0.0001);
    try std.testing.expectApproxEqAbs(-2.0, v2.y(), 0.0001);
    try std.testing.expectApproxEqAbs(4.2, v2.z(), 0.0001);
}

test "vec arithmetic" {
    const v = amth.Vec2.from(2, -1);
    const v2 = amth.Vec2.from(1.5, 4.2);

    const sum = amth.Vec2.add(v, v2);
    const diff = amth.Vec2.add(v, v2.neg());

    try std.testing.expectApproxEqAbs(3.5, sum.x(), 0.0001);
    try std.testing.expectApproxEqAbs(3.2, sum.y(), 0.0001);

    try std.testing.expectApproxEqAbs(0.5, diff.x(), 0.0001);
    try std.testing.expectApproxEqAbs(-5.2, diff.y(), 0.0001);
}

test "Vec2 scale" {
    var v = amth.Vec2.from(2, -1);

    v.scale(3.0);

    try std.testing.expectApproxEqAbs(6, v.x(), 0.0001);
    try std.testing.expectApproxEqAbs(-3, v.y(), 0.0001);
}

test "Vec length" {
    const v = amth.Vec2.from(2, -1);
    const len = v.length();
    const square_len = v.squareLength();

    try std.testing.expectApproxEqAbs(amth.sqrt(5.0), len, 0.0001);
    try std.testing.expectApproxEqAbs(5.0, square_len, 0.0001);
}

test "Vec dot" {
    const v = amth.Vec3.from(1, 2, 3);
    const v2 = amth.Vec3.from(4, 5, 6);

    const dot = amth.Vec3.dot(v, v2);

    try std.testing.expectApproxEqAbs(32.0, dot, 0.0001);
}

test "Vec normalize" {
    var x = amth.Vec3.from(1, 0, 0);
    var y = amth.Vec3.from(0, 1, 0);
    var z = amth.Vec3.from(0, 0, 1);

    x.normalize();
    y.normalize();
    z.normalize();

    try std.testing.expectEqual(@Vector(3, f32){ 1, 0, 0 }, x.data);
    try std.testing.expectEqual(@Vector(3, f32){ 0, 1, 0 }, y.data);
    try std.testing.expectEqual(@Vector(3, f32){ 0, 0, 1 }, z.data);
}

test "Mat4 scale" {
    var identity = amth.Mat4.identity();
    identity.scale(3.0);

    try std.testing.expectEqual(amth.Mat4.diagonal(3.0).data, identity.data);
}

test "Mat4 multiply" {
    const m1 = amth.Mat4{
        .data = .{
            1, 2, 2, 2,
            2, 3, 2, 1,
            2, 2, 1, 4,
            1, 1, 1, 1,
        },
    };

    const m2 = amth.Mat4{
        .data = .{
            -1,   0,     0,    2,
            0.25, 0.75,  0.25, -2.25,
            0.5,  -0.5,  -0.5, 1.5,
            0.25, -0.25, 0.25, -0.25,
        },
    };

    const m: amth.Mat4 = amth.Mat4.multiply(m1, m2);

    try std.testing.expectEqual(amth.Mat4.identity().data, m.data);
}

test "Mat4 inverse" {
    const m1 = amth.Mat4{
        .data = .{
            1, 2, 2, 2,
            2, 3, 2, 1,
            2, 2, 1, 4,
            1, 1, 1, 1,
        },
    };

    const m2 = amth.Mat4{
        .data = .{
            -1,   0,     0,    2,
            0.25, 0.75,  0.25, -2.25,
            0.5,  -0.5,  -0.5, 1.5,
            0.25, -0.25, 0.25, -0.25,
        },
    };

    const m: amth.Mat4 = amth.Mat4.inverse(m1);

    try std.testing.expectEqual(m2.data, m.data);
}

test "clamp" {
    try std.testing.expectEqual(0.0, amth.clamp(0.0, -1.0, 1.0));
    try std.testing.expectEqual(2.0, amth.clamp(3.0, 1.0, 2.0));
    try std.testing.expectEqual(4.0, amth.clamp(3.0, 4.0, 8.0));
}

test "Vec2 lerp" {
    const a = amth.Vec2.from(1.0, 2.0);
    const b = amth.Vec2.from(4.0, 6.0);

    try std.testing.expectEqual(amth.Vec2.from(1.0, 2.0), amth.Vec2.lerp(a, b, 0.0));
    try std.testing.expectEqual(amth.Vec2.from(4.0, 6.0), amth.Vec2.lerp(a, b, 1.0));
    try std.testing.expectEqual(amth.Vec2.from(2.5, 4.0), amth.Vec2.lerp(a, b, 0.5));
    try std.testing.expectEqual(amth.Vec2.from(1.75, 3.0), amth.Vec2.lerp(a, b, 0.25));
    try std.testing.expectEqual(amth.Vec2.from(3.25, 5.0), amth.Vec2.lerp(a, b, 0.75));
}
