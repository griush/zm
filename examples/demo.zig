const std = @import("std");
const zm = @import("zm");

pub fn main() !void {
    std.debug.print("easing and animations\n", .{});
    var val: f32 = zm.ease(0, 100, 0.25, zm.EaseType.ease_in_out);
    std.debug.print("  ease_in_out: 0 -> 100 at 25% = {d}\n", .{val});
    val = zm.ease(0, 100, 0.50, zm.EaseType.ease_in_out);
    std.debug.print("  ease_in_out: 0 -> 100 at 50% = {d}\n", .{val});
    val = zm.ease(0, 100, 0.75, zm.EaseType.ease_in_out);
    std.debug.print("  ease_in_out: 0 -> 100 at 75% = {d}\n", .{val});
}
