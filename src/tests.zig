const std = @import("std");
const amth = @import("amth");

test "Vec initialization" {
    const v = amth.Vec2{ 2, -1 };
    const v2 = amth.Vec3{ 1.5, -2, 4.2 };

    try std.testing.expectApproxEqAbs(2, v[0], 0.0001);
    try std.testing.expectApproxEqAbs(-1, v[1], 0.0001);

    try std.testing.expectApproxEqAbs(1.5, v2[0], 0.0001);
    try std.testing.expectApproxEqAbs(-2.0, v2[1], 0.0001);
    try std.testing.expectApproxEqAbs(4.2, v2[2], 0.0001);
}

test "vec arithmetic" {
    const v = amth.Vec2{ 2, -1 };
    const v2 = amth.Vec2{ 1.5, 4.2 };

    const sum = v + v2;
    const diff = v - v2;

    try std.testing.expectApproxEqAbs(3.5, sum[0], 0.0001);
    try std.testing.expectApproxEqAbs(3.2, sum[1], 0.0001);

    try std.testing.expectApproxEqAbs(0.5, diff[0], 0.0001);
    try std.testing.expectApproxEqAbs(-5.2, diff[1], 0.0001);
}

test "Vec2 scale" {
    var v = amth.Vec2{ 2, -1 };

    amth.scale(amth.Vec2, &v, 3);

    try std.testing.expectApproxEqAbs(6, v[0], 0.0001);
    try std.testing.expectApproxEqAbs(-3, v[1], 0.0001);
}

test "Vec length" {
    const v = amth.Vec2{ 2, -1 };
    const len = amth.length(v);
    const square_len = amth.squareLength(v);

    try std.testing.expectApproxEqAbs(@sqrt(5.0), len, 0.0001);
    try std.testing.expectApproxEqAbs(5.0, square_len, 0.0001);
}

test "Vec dot" {
    const v = amth.Vec3{ 1, 2, 3 };
    const v2 = amth.Vec3{ 4, 5, 6 };

    const dot = amth.dot(v, v2);

    try std.testing.expectApproxEqAbs(32.0, dot, 0.0001);
}

test "Vec normalize" {
    var x = amth.Vec3{ 1, 0, 0 };
    var y = amth.Vec3{ 0, 1, 0 };
    var z = amth.Vec3{ 0, 0, 1 };

    amth.normalize(amth.Vec3, &x);
    amth.normalize(amth.Vec3, &y);
    amth.normalize(amth.Vec3, &z);

    try std.testing.expectEqual(amth.Vec3{ 1, 0, 0 }, x);
    try std.testing.expectEqual(amth.Vec3{ 0, 1, 0 }, y);
    try std.testing.expectEqual(amth.Vec3{ 0, 0, 1 }, z);
}
