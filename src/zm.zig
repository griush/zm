//! zm - Fast, Zig math library, fully cross-platform.
//! zm uses a +Y-up, right-handed coordinate system,
//! for all types, the default is f64.
//! Type names ending with `f` are f32.
//! Matrices are row-major.

const std = @import("std");

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
        .linear => std.math.lerp(a, b, t),
        .ease_in => std.math.lerp(a, b, t * t),
        .ease_out => std.math.lerp(a, b, 1 - (1 - t) * (1 - t)),
        .ease_in_out => std.math.lerp(a, b, -(std.math.cos(std.math.pi * t) - 1.0) / 2.0),
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

// Builtin Mat2Base types
pub const Mat2f = matrix.Mat2Base(f32);
pub const Mat2 = matrix.Mat2Base(f64);

// Builtin Mat3Base types
pub const Mat3f = matrix.Mat3Base(f32);
pub const Mat3 = matrix.Mat3Base(f64);

// Builtin Mat4Base types
pub const Mat4f = matrix.Mat4Base(f32);
pub const Mat4 = matrix.Mat4Base(f64);

// quaternion namespace
pub const quaternion = @import("quaternion.zig");

// Builtin Quaternion types
pub const Quaternionf = quaternion.QuaternionBase(f32);
pub const Quaternion = quaternion.QuaternionBase(f64);

// ray namespace
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
