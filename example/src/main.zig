const std = @import("std");
const zm = @import("zm");

pub fn main() !void {
    // Basic functions
    const radians = zm.toRadians(180.0); // also toDegrees
    std.debug.print("Radians: {d}\n", .{radians});

    // Useful functions for animation
    _ = zm.easeInOutCubic(@as(f32, 0.75));

    // Vector types are created with zm.Vec function.
    // It takes the number of elements(size) and the base type and returns
    // the vector type. There are however builtin types: VecX => Vector of size X
    // and f32 as base type, and VecXd => Vector of size X and f64 as base type.
    const v1 = zm.Vec2.init(2.0, 1.5);
    std.debug.print("v1: {any}\n", .{v1});
    std.debug.print("v1.neg(): {any}\n", .{v1.neg()});
    std.debug.print("v1.scale(2): {any}\n", .{v1.scale(2)});
    std.debug.print("v1.length(): {d}\n", .{v1.len()});

    // Similar operations with Vec3 and Vec4
    const v2 = zm.Vec3.up();
    const v3 = zm.Vec3.right();
    std.debug.print("mid point: {any}\n", .{zm.Vec3.lerp(v2, v3, 0.5)});

    // Transformation matrices
    const projection = zm.Mat4.perspective(zm.toRadians(60.0), 16.0 / 9.0, 0.05, 100.0);
    const view = zm.Mat4.lookAt(zm.Vec3.init(3, 3, 3), zm.Vec3.zero(), zm.Vec3.up());
    const view_proj = zm.Mat4.multiply(projection, view);
    _ = view_proj; // Use view proj

    // Quaternions for rotations
    const rotation = zm.Quaternion.fromEulerAngles(zm.Vec3.up().scale(zm.toRadians(45.0))); // Set rotation matrix 45 degrees on y axis
    const model = zm.Mat4.translation(2, -3, 0).multiply(zm.Mat4.fromQuaternion(rotation)).multiply(zm.Mat4.scaling(1.5, 1.5, 1.5));
    _ = model; // Use model
}
