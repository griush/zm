const std = @import("std");
const zm = @import("zm");

pub fn main() !void {
    // Basic functions
    const radians = zm.toRadians(180.0); // also toDegrees
    std.debug.print("Radians: {d}\n", .{radians});

    // For each type, there is a base that tekes in the inner type
    // Example: Vec2Base(f32), Mat3Base(u16), QuaternionBase(f64)...
    // There are builtin types: Vec2, Vec3, Mat2, Mat4... which are aliases
    // for ...Base(f32), there are also type aliases ending with 'i'(implementing
    // i32) and ending with 'd'(implementing f64)
    // const v1 = zm.Vec2.from(.{ 2.0, 1.5 });
    // std.debug.print("v1: {any}\n", .{v1});
    // std.debug.print("v1.neg(): {any}\n", .{v1.neg()});
    // std.debug.print("v1.scale(2): {any}\n", .{v1.scale(2)});
    // std.debug.print("v1.length(): {d}\n", .{v1.length()});

    // Similar operations with Vec3 and Vec4
    // lerp temporarily removed
    // const v2 = zm.Vec3.up();
    // const v3 = zm.Vec3.right();
    // std.debug.print("mid point: {any}\n", .{zm.Vec3.lerp(v2, v3, 0.5)});

    // Transformation matrices
    const projection = zm.Mat4.perspective(zm.toRadians(60.0), 16.0 / 9.0, 0.05, 100.0);
    const view = zm.Mat4.translation(0.0, 0.75, 5.0);
    const view_proj = zm.Mat4.multiply(projection, view);
    _ = view_proj; // Use view proj
}
