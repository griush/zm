//! zm - Fast, Zig math library, fully cross-platform.
//! zm uses a +Y-up, right-handed coordinate system,
//! for all types, the default is f64.
//! type names ending with `f` are f32.

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
/// To lerp vectors use `zm.vec.lerp`.
pub fn lerp(a: anytype, b: anytype, t: anytype) @TypeOf(a, b, t) {
    const T = @TypeOf(a, b, t);
    return @mulAdd(T, b - a, t, a);
}

/// `x` must be numeric.
pub fn sigmoid(x: anytype) @TypeOf(x) {
    return 1.0 / (1.0 + @exp(-x));
}

pub const EaseType = enum {
    linear,
    ease_in,
    ease_out,
    ease_in_out,
};

pub fn ease(a: anytype, b: anytype, t: anytype, ease_type: EaseType) @TypeOf(a, b, t) {
    return switch (ease_type) {
        .linear => lerp(a, b, t),
        .ease_in => lerp(a, b, t * t),
        .ease_out => lerp(a, b, 1 - (1 - t) * (1 - t)),
        .ease_in_out => lerp(a, b, -(std.math.cos(std.math.pi * t) - 1.0) / 2.0),
    };
}

// vec namespace
pub const vec = @import("vector.zig");
pub const Vec2f = vec.Vec2f;
pub const Vec3f = vec.Vec3f;
pub const Vec4f = vec.Vec4f;
pub const Vec2 = vec.Vec2;
pub const Vec3 = vec.Vec3;
pub const Vec4 = vec.Vec4;

// matrices
pub const matrix = @import("matrix.zig");
const Mat2Base = matrix.Mat2Base;
const Mat3Base = matrix.Mat3Base;
const Mat4Base = matrix.Mat4Base;

// Builtin Mat2Base types
pub const Mat2f = Mat2Base(f32);
pub const Mat2 = Mat2Base(f64);

// Builtin Mat3Base types
pub const Mat3f = Mat3Base(f32);
pub const Mat3 = Mat3Base(f64);

// Builtin Mat4Base types
pub const Mat4f = Mat4Base(f32);
pub const Mat4 = Mat4Base(f64);

// quaternion namespace
pub const quaternion = @import("quaternion.zig");

// Builtin Quaternion types
pub const Quaternionf = quaternion.QuaternionBase(f32);
pub const Quaternion = quaternion.QuaternionBase(f64);

// Rays
pub const ray = @import("ray.zig");

// Builtin Ray types
pub const Rayf = ray.RayBase(f32);
pub const Ray = ray.RayBase(f64);

// aabb namespace
pub const aabb = @import("aabb.zig");

// aabb builtins
/// 3-dimensional AABB
pub const AABBf = aabb.AABBBase(3, f32);
pub const AABB = aabb.AABBBase(3, f64);
