const std = @import("std");

pub fn Vec(len: comptime_int, comptime T: type) type {
    const type_info = @typeInfo(T);
    switch (type_info) {
        .Int, .Float => {},
        else => @compileError("Vec only supports numerical type. Type '" ++ @typeName(T) ++ "' is not supported"),
    }

    return struct {
        const Self = @This();

        data: @Vector(len, T),

        pub fn from(in: @Vector(len, T)) Self {
            return Self{
                .data = in,
            };
        }

        pub fn right() Self {
            if (len != 3) {
                @compileError("Vector must have three elements");
            }

            return Self{
                .data = .{ 1, 0, 0 },
            };
        }

        pub fn up() Self {
            if (len != 3) {
                @compileError("Vector must have three elements");
            }

            return Self{
                .data = .{ 0, 1, 0 },
            };
        }

        pub fn forward() Self {
            if (len != 3) {
                @compileError("Vector must have three elements");
            }

            return Self{
                .data = .{ 0, 0, 1 },
            };
        }

        pub fn x(self: Self) T {
            if (len < 1) {
                @compileError("len must be at least 1 to get x component");
            }

            return self.data[0];
        }

        pub fn y(self: Self) T {
            if (len < 2) {
                @compileError("len must be at least 2 to get y component");
            }

            return self.data[1];
        }

        pub fn z(self: Self) T {
            if (len < 3) {
                @compileError("len must be at least 3 to get z component");
            }

            return self.data[2];
        }

        pub fn w(self: Self) T {
            if (len < 4) {
                @compileError("len must be at least 4 to get w component");
            }

            return self.data[3];
        }

        pub fn add(l: Self, r: Self) Self {
            return Self{
                .data = l.data + r.data,
            };
        }

        pub fn sub(l: Self, r: Self) Self {
            return Self{
                .data = l.data - r.data,
            };
        }

        pub fn neg(self: Self) Self {
            return Self{
                .data = -self.data,
            };
        }

        pub inline fn scale(self: Self, s: T) Self {
            return Self{
                .data = self.data * @as(@Vector(len, T), @splat(s)),
            };
        }

        pub fn squareLength(self: Self) T {
            return @reduce(.Add, self.data * self.data);
        }

        pub fn length(self: Self) T {
            return @sqrt(@reduce(.Add, self.data * self.data));
        }

        pub fn normalized(self: Self) Self {
            return self.scale(1 / self.length());
        }

        pub fn dot(l: Self, r: Self) T {
            return @reduce(.Add, l.data * r.data);
        }

        pub fn cross(l: Self, r: Self) Self {
            if (len != 3) {
                @compileError("Vector parameters must have three elements for cross() to be defined");
            }

            const self1 = @shuffle(T, l.data, l.vals, [3]u8{ 1, 2, 0 });
            const self2 = @shuffle(T, l.data, l.vals, [3]u8{ 2, 0, 1 });
            const other1 = @shuffle(T, r.data, r.data, [3]u8{ 2, 0, 1 });
            const other2 = @shuffle(T, r.data, r.data, [3]u8{ 1, 2, 0 });

            return Self{
                .data = self1 * other2 - self2 * other1,
            };
        }

        // TODO: Finish format
        // /// This function allows `Vectors` to be formated by Zig's `std.fmt`.
        // /// Example: `std.debug.print("Vec: {any}", .{ zm.Vec3.up() });`
        // pub fn format(
        //     v: Self,
        //     comptime fmt: []const u8,
        //     options: std.fmt.FormatOptions,
        //     writer: anytype,
        // ) !void {
        //     _ = fmt;
        //     _ = options;
        //
        //     try writer.print("(" ++ ("{d}, " ** len) ++ ")", .{ });
        // }

        // TODO: Lerp
    };
}
