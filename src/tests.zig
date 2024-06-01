const std = @import("std");
const mth = @import("root.zig");

test "Vec2 initialization" {
    const v = mth.Vec2{ 2, -1 };

    try std.testing.expectEqual(2, v[0]);
    try std.testing.expectEqual(-1, v[1]);
}

test "Vec2 scale" {
    var v = mth.Vec2{ 2, -1 };

    mth.scale(mth.Vec2, &v, 3);

    try std.testing.expectEqual(6, v[0]);
    try std.testing.expectEqual(-3, v[1]);
}
