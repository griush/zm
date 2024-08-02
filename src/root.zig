//! zm - SIMD Math library fully cross-platform

const std = @import("std");

/// Takes in a floating point type representing degrees.
/// Returns the equivalent in radians.
pub fn toRadians(degress: anytype) @TypeOf(degress) {
    const T = @TypeOf(degress);
    const type_info = @typeInfo(T);
    return switch (type_info) {
        .Float, .ComptimeFloat => degress * std.math.rad_per_deg,
        else => @compileError("toRadians not implemented for " ++ @typeName(T)),
    };
}

/// Takes in a floating point type representing radians.
/// Returns the equivalent in degrees.
pub fn toDegrees(radians: anytype) @TypeOf(radians) {
    const T = @TypeOf(radians);
    const type_info = @typeInfo(T);
    return switch (type_info) {
        .Float, .ComptimeFloat => radians * std.math.deg_per_rad,
        else => @compileError("toDegrees not implemented for " ++ @typeName(T)),
    };
}

/// Clamps the value `n` between `low_bound` and `high_bound`.
/// Must be a floating point type.
pub fn clamp(n: anytype, low_bound: @TypeOf(n), high_bound: @TypeOf(n)) @TypeOf(n) {
    const T = @TypeOf(n);
    const type_info = @typeInfo(T);
    return switch (type_info) {
        .Int, .Float, .ComptimeInt, .ComptimeFloat => @max(low_bound, @min(n, high_bound)),
        else => @compileError("clamp not implemented for " ++ @typeName(T)),
    };
}

/// No extrapolation, clamps `t`.
pub fn lerp(a: anytype, b: @TypeOf(a), t: @TypeOf(a)) @TypeOf(a) {
    const T = @TypeOf(a);
    const type_info = @typeInfo(T);
    return switch (type_info) {
        .Float, .ComptimeFloat => {
            const l = clamp(t, 0.0, 1.0);
            return (1 - l) * a + l * b;
        },
        else => @compileError("lerp not implemented for " ++ @typeName(T)),
    };
}

// Vectors
const Vec = @import("vector.zig").Vec;

// Builtin Vec2Base types
pub const Vec2 = Vec(2, f32);
pub const Vec2d = Vec(2, f64);
pub const Vec2i = Vec(2, i32);

// Builtin Vec3Base types
pub const Vec3 = Vec(3, f32);
pub const Vec3d = Vec(3, f64);
pub const Vec3i = Vec(3, i32);

// Builtin Vec4Base types
pub const Vec4 = Vec(4, f32);
pub const Vec4d = Vec(4, f64);
pub const Vec4i = Vec(4, i32);

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
