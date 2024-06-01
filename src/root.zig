const std = @import("std");

const RealType = f32;

/// Vec2 type
pub const Vec2 = @Vector(2, RealType);

/// Vec3 type
pub const Vec3 = @Vector(3, RealType);

/// Vec4 type
pub const Vec4 = @Vector(4, RealType);

/// Scales a vec of given type
pub fn scale(comptime T: type, v: *T, s: RealType) void {
    std.debug.assert(T == Vec2 or T == Vec3 or T == Vec4);
    v.* *= @splat(s);
}

/// Returns the length of the given vector
pub fn length(v: anytype) RealType {
    std.debug.assert(@TypeOf(v) == Vec2 or @TypeOf(v) == Vec3 or @TypeOf(v) == Vec4);

    switch (@TypeOf(v)) {
        Vec2 => {
            return @sqrt(v[0] * v[0] + v[1] * v[1]);
        },
        Vec3 => {
            return @sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
        },
        Vec4 => {
            return @sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2] + v[3] * v[3]);
        },
        else => unreachable, // made unreachable by assert above
    }
}

/// Returns the length of the given vector
pub fn squareLength(v: anytype) RealType {
    std.debug.assert(@TypeOf(v) == Vec2 or @TypeOf(v) == Vec3 or @TypeOf(v) == Vec4);

    switch (@TypeOf(v)) {
        Vec2 => {
            return v[0] * v[0] + v[1] * v[1];
        },
        Vec3 => {
            return v[0] * v[0] + v[1] * v[1] + v[2] * v[2];
        },
        Vec4 => {
            return v[0] * v[0] + v[1] * v[1] + v[2] * v[2] + v[3] * v[3];
        },
        else => unreachable, // made unreachable by assert above
    }
}
