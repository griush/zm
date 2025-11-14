const std = @import("std");
const zm = @import("zm");

pub fn main() !void {
    std.debug.print("zm demo\n\n", .{});

    std.debug.print("easing and animations\n", .{});
    var val: f32 = zm.ease(0, 100, 0.25, zm.EaseType.ease_in_out);
    std.debug.print("  ease_in_out: 0 -> 100 at 25% = {d}\n", .{val});
    val = zm.ease(0, 100, 0.50, zm.EaseType.ease_in_out);
    std.debug.print("  ease_in_out: 0 -> 100 at 50% = {d}\n", .{val});
    val = zm.ease(0, 100, 0.75, zm.EaseType.ease_in_out);
    std.debug.print("  ease_in_out: 0 -> 100 at 75% = {d}\n", .{val});

    std.debug.print("vectors\n", .{});
    const v1 = zm.Vec(3, f32){ .data = .{ 1.0, 1.0, 0.0 } };
    std.debug.print("  v1 = ({d},{d},{d})\n", .{v1.data[0], v1.data[1], v1.data[2]});
    std.debug.print("  v1.len() = {d}\n", .{v1.len()});
    const v1_norm = v1.norm();
    std.debug.print("  v1.norm = ({d},{d},{d})\n", .{v1_norm.data[0], v1_norm.data[1], v1_norm.data[2]});

    const right = zm.Vec3{ .data = .{ 1.0, 0.0, 0.0} };
    const up = zm.Vec3{ .data = .{ 0.0, 1.0, 0.0} };
    const up_x_rightRH = right.crossRH(up);
    std.debug.print("  right x up RH = ({d},{d},{d})\n", .{up_x_rightRH.data[0], up_x_rightRH.data[1], up_x_rightRH.data[2]});
    const up_x_rightLH = right.crossLH(up);
    std.debug.print("  right x up LH = ({d},{d},{d})\n", .{up_x_rightLH.data[0], up_x_rightLH.data[1], up_x_rightLH.data[2]});

    std.debug.print("matrices\n", .{});
    std.debug.print("TODO\n", .{});
    std.debug.print("ray\n", .{});
    std.debug.print("TODO\n", .{});
    std.debug.print("quaternion\n", .{});
    std.debug.print("TODO\n", .{});
    std.debug.print("aabb\n", .{});
    std.debug.print("TODO\n", .{});
}
