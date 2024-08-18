//! zm - Fast, Zig math library, fully cross-platform.
//! zm uses a +Y-up, right-handed coordinate system

const std = @import("std");

/// Takes in a floating point type representing degrees.
/// Returns the equivalent in radians.
pub fn toRadians(degress: anytype) @TypeOf(degress) {
    return degress * std.math.rad_per_deg;
}

/// Takes in a floating point type representing radians.
/// Returns the equivalent in degrees.
pub fn toDegrees(radians: anytype) @TypeOf(radians) {
    return radians * std.math.deg_per_rad;
}

/// Clamps the value `n` between `low_bound` and `high_bound`.
/// Must be a floating point type.
pub fn clamp(n: anytype, low_bound: anytype, high_bound: anytype) @TypeOf(n, low_bound, high_bound) {
    return @max(low_bound, @min(n, high_bound));
}

/// No extrapolation, clamps `t`.
pub fn lerp(a: anytype, b: anytype, t: anytype) @TypeOf(a, b, t) {
    const T = @TypeOf(a, b, t);
    return @mulAdd(T, b - a, t, a);
}

/// `value` must be numeric.
pub fn sigmoid(value: anytype) @TypeOf(value) {
    return 1.0 / (1.0 + @exp(-value));
}

/// `value` must be a floating point number.
/// It must be between `0`(beginning of the animation) and `1`(end of the animation)
pub fn easeInOutCubic(value: anytype) @TypeOf(value) {
    if (@typeInfo(@TypeOf(value)) != .Float) @compileError("easeInOutCubic not implemented for " ++ @typeName(@TypeOf(value)));

    if (value < 0.5) {
        return 4 * value * value * value;
    } else {
        return 1 - std.math.pow(@TypeOf(value), -2 * value + 2, 3) / 2;
    }
}

// Vectors
pub const Vec = @import("vector.zig").Vec;

// Builtin Vec2Base types
pub const Vec2 = Vec(2, f32);
pub const Vec2d = Vec(2, f64);

// Builtin Vec3Base types
pub const Vec3 = Vec(3, f32);
pub const Vec3d = Vec(3, f64);

// Builtin Vec4Base types
pub const Vec4 = Vec(4, f32);
pub const Vec4d = Vec(4, f64);

// Matrices
const matrix = @import("matrix.zig");
pub const Mat2Base = matrix.Mat2Base;
pub const Mat3Base = matrix.Mat3Base;
pub const Mat4Base = matrix.Mat4Base;

// Builtin Mat2Base types
pub const Mat2 = Mat2Base(f32);
pub const Mat2d = Mat2Base(f64);

// Builtin Mat3Base types
pub const Mat3 = Mat3Base(f32);
pub const Mat3d = Mat3Base(f64);

// Builtin Mat4Base types
pub const Mat4 = Mat4Base(f32);
pub const Mat4d = Mat4Base(f64);

pub const QuaternionBase = @import("quaternion.zig").QuaternionBase;

// Builtin Quaternion types
pub const Quaternion = QuaternionBase(f32);
pub const Quaterniond = QuaternionBase(f64);

// Ray
pub const Ray = @import("ray.zig");
