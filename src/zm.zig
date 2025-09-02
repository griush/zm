//! zm - Fast, Zig math library, fully cross-platform.
//! For all types, the default is f64. Type names ending with `f` are f32.
//! Use RH/LH functions to choose handedness acordingly.

const std = @import("std");

pub const EulerOrder = enum {
    xyz,
    xzy,
    yxz,
    yzx,
    zxy,
    zyx,
};

pub const FrameConvention = enum {
    intrinsic,
    extrinsic,
};

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

/// `a` and `b` must be numeric types.
/// `t` should be between 0 and 1.
pub fn ease(a: anytype, b: anytype, t: f32, ease_type: EaseType) @TypeOf(a, b, t) {
    return switch (ease_type) {
        .linear => std.math.lerp(a, b, t),
        .ease_in => std.math.lerp(a, b, t * t),
        .ease_out => std.math.lerp(a, b, 1 - (1 - t) * (1 - t)),
        .ease_in_out => std.math.lerp(a, b, -(std.math.cos(std.math.pi * t) - 1.0) / 2.0),
    };
}

// vec namespace
pub const vec = @import("vec.zig");
pub const Vec = vec.Vec;

// vec builtins
pub const Vec2f = vec.Vec2f;
pub const Vec3f = vec.Vec3f;
pub const Vec4f = vec.Vec4f;
pub const Vec2 = vec.Vec2;
pub const Vec3 = vec.Vec3;
pub const Vec4 = vec.Vec4;

// matrix namespace
pub const matrix = @import("matrix.zig");

// matrix builtins
pub const Mat2f = matrix.Mat2f;
pub const Mat2 = matrix.Mat2;

pub const Mat3f = matrix.Mat3f;
pub const Mat3 = matrix.Mat3;

pub const Mat4f = matrix.Mat4f;
pub const Mat4 = matrix.Mat4;

// quaternion namespace
pub const quaternion = @import("quaternion.zig");
pub const Quaternion = quaternion.Quaternion;

// quaternion builtins
pub const Quaternionf = quaternion.Quaternion(f32);
pub const Quaterniond = quaternion.Quaternion(f64);

// ray namespace
pub const ray = @import("ray.zig");
pub const Ray = ray.Ray;

// ray builtins
pub const Rayf = ray.Ray(f32);
pub const Rayd = ray.Ray(f64);

// aabb namespace
pub const aabb = @import("aabb.zig");
pub const AABB = aabb.AABB;

// aabb builtins
pub const AABBf = aabb.AABB(3, f32);
pub const AABBd = aabb.AABB(3, f64);
