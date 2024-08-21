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

/// `t` must be numeric.
pub fn sigmoid(t: anytype) @TypeOf(t) {
    return 1.0 / (1.0 + @exp(-t));
}

/// `t` must be a floating point number.
/// `t` must be between `0`(beginning of the animation) and `1`(end of the animation)
pub fn easeInOutCubic(t: anytype) @TypeOf(t) {
    if (@typeInfo(@TypeOf(t)) != .Float) @compileError("easeInOutCubic not implemented for " ++ @typeName(@TypeOf(t)));

    if (t < 0.5) {
        return 4 * t * t * t;
    } else {
        return 1 - std.math.pow(@TypeOf(t), -2 * t + 2, 3) / 2;
    }
}

// vec namespace
pub const vec = @import("vector.zig");

pub const Vec2 = vec.Vec2(f32);
pub const Vec3 = vec.Vec3(f32);
pub const Vec4 = vec.Vec4(f32);

pub const DVec2 = vec.Vec2(f64);
pub const DVec3 = vec.Vec3(f64);
pub const DVec4 = vec.Vec4(f64);

// Matrices
const matrix = @import("matrix.zig");
pub const Mat2Base = matrix.Mat2Base;
pub const Mat3Base = matrix.Mat3Base;
pub const Mat4Base = matrix.Mat4Base;

// Builtin Mat2Base types
pub const Mat2 = Mat2Base(f32);
pub const DMat2 = Mat2Base(f64);

// Builtin Mat3Base types
pub const Mat3 = Mat3Base(f32);
pub const DMat3 = Mat3Base(f64);

// Builtin Mat4Base types
pub const Mat4 = Mat4Base(f32);
pub const DMat4 = Mat4Base(f64);

pub const QuaternionBase = @import("quaternion.zig").QuaternionBase;

// Builtin Quaternion types
pub const Quaternion = QuaternionBase(f32);
pub const DQuaternion = QuaternionBase(f64);

// Rays
pub const RayBase = @import("ray.zig").RayBase;

// Builtin Ray types
pub const Ray = RayBase(f32);
pub const DRay = RayBase(f32);
