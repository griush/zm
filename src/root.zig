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

/// Normilizes the given vector (modifies)
pub fn normalize(T: type, v: *T) void {
    std.debug.assert(T == Vec2 or T == Vec3 or T == Vec4);

    v.* /= @splat(length(v.*));
}

/// Returns the length of the given vector
pub fn dot(l: anytype, r: anytype) RealType {
    std.debug.assert(@TypeOf(l) == @TypeOf(r));
    std.debug.assert(@TypeOf(l) == Vec2 or @TypeOf(l) == Vec3 or @TypeOf(l) == Vec4);

    switch (@TypeOf(l)) {
        Vec2 => {
            return l[0] * r[0] + l[1] * r[1];
        },
        Vec3 => {
            return l[0] * r[0] + l[1] * r[1] + l[2] * r[2];
        },
        Vec4 => {
            return l[0] * r[0] + l[1] * r[1] + l[2] * r[2] + l[3] * r[3];
        },
        else => unreachable, // made unreachable by assert above
    }
}

pub fn cross(l: Vec3, r: Vec3) Vec3 {
    return .{
        l[1] * r[2] - l[2] * r[1],
        l[2] * r[0] - l[0] * r[2],
        l[0] * r[1] - l[1] * r[0],
    };
}

/// Mat4 type
pub const Mat4 = @Vector(16, RealType);

pub fn diagonalMat4(r: RealType) Mat4 {
    return Mat4{
        r, 0, 0, 0,
        0, r, 0, 0,
        0, 0, r, 0,
        0, 0, 0, r,
    };
}

pub fn identity() Mat4 {
    return diagonalMat4(1.0);
}
