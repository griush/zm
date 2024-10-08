const std = @import("std");
const zm = @import("zm");

pub fn main() !void {
    // Basic functions
    const radians = zm.toRadians(180.0); // also toDegrees
    std.debug.print("Radians: {d}\n", .{radians});

    _ = zm.ease(0, 90, 0.5, zm.EaseType.ease_in_out);

    // Vector types are created with zm.Vec function.
    // It takes the number of elements(size) and the base type and returns
    // the vector type. There are however builtin types: VecX => Vector of size X
    // and f32 as base type, and VecXd => Vector of size X and f64 as base type.
    const v1 = zm.Vec2f{ 2.0, 1.5 };
    std.debug.print("v1: {any}\n", .{v1});
    std.debug.print("v1.neg(): {any}\n", .{-v1});
    std.debug.print("v1.scale(2): {any}\n", .{zm.vec.scale(v1, 2)});
    std.debug.print("v1.length(): {d}\n", .{zm.vec.len(v1)});

    // Similar operations with Vec3 and Vec4
    const v2 = zm.vec.up(f32);
    const v3 = zm.vec.right(f32);
    std.debug.print("mid point: {any}\n", .{zm.vec.lerp(v2, v3, 0.5)});

    // Transformation matrices
    const projection = zm.Mat4f.perspective(zm.toRadians(60.0), 16.0 / 9.0, 0.05, 100.0);
    const view = zm.Mat4f.lookAt(zm.Vec3f{ 3, 3, 3 }, zm.vec.zero(3, f32), zm.vec.up(f32));
    const view_proj = zm.Mat4f.multiply(projection, view);
    _ = view_proj; // Use view proj

    // Quaternions for rotations
    const rotation = zm.Quaternionf.fromEulerAngles(zm.vec.scale(zm.vec.up(f32), zm.toRadians(45.0))); // Set rotation matrix 45 degrees on y axis
    const model = zm.Mat4f.translation(2, -3, 0).multiply(zm.Mat4f.fromQuaternion(rotation)).multiply(zm.Mat4f.scaling(1.5, 1.5, 1.5));
    _ = model; // Use model
}
