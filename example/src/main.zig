const std = @import("std");
const zm = @import("zm");

pub fn main() !void {
    // Basic functions
    const radians = zm.toRadians(180.0); // also toDegrees
    std.debug.print("Radians: {d}\n", .{radians});

    _ = zm.ease(0, 90, 0.5, zm.EaseType.ease_in_out);

    // use `Vec2f` for a 32-bit float vector
    const v1 = zm.Vec2{ 2.0, 1.5 };
    std.debug.print("v1: {any}\n", .{v1});
    std.debug.print("v1.neg(): {any}\n", .{-v1});
    std.debug.print("v1.scale(2): {any}\n", .{zm.vec.scale(v1, 2)});
    std.debug.print("v1.length(): {d}\n", .{zm.vec.len(v1)});

    // Similar operations with Vec3 and Vec4
    const v2 = zm.vec.up(f64);
    const v3 = zm.vec.right(f64);
    std.debug.print("mid point: {any}\n", .{zm.vec.lerp(v2, v3, 0.5)});

    // Transformation matrices
    const projection = zm.Mat4.perspective(zm.toRadians(60.0), 16.0 / 9.0, 0.05, 100.0);
    const view = zm.Mat4.lookAt(zm.Vec3{ 3, 3, 3 }, zm.vec.zero(3, f64), zm.vec.up(f64));
    const view_proj = zm.Mat4.multiply(projection, view);
    _ = view_proj; // Use view proj

    // Quaternions for rotations
    const rotation = zm.Quaternion.fromEulerAngles(zm.vec.scale(zm.vec.up(f64), zm.toRadians(45.0))); // set rotation matrix 45 degrees on y axis
    const model = zm.Mat4.translation(2, -3, 0).multiply(zm.Mat4.fromQuaternion(rotation)).multiply(zm.Mat4.scaling(1.5, 1.5, 1.5));
    _ = model; // Use model
}
