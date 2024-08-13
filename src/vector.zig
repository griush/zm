const std = @import("std");

const root = @import("zm.zig");

/// Returns a vector type of dimension `len` and `Element` as the element type.
pub fn Vec(len: comptime_int, comptime Element: type) type {
    const type_info = @typeInfo(Element);
    comptime switch (type_info) {
        .Int, .Float => {},
        else => @compileError("Vec only supports numerical type. Type '" ++ @typeName(Element) ++ "' is not supported"),
    };

    if (len < 1) @compileError("Vector len must be positive and non-zero");

    return struct {
        const Self = @This();
        const Float = std.meta.Float;

        const DataType = [len]Element;

        data: DataType,

        const precision = switch (type_info) {
            .Int => |int| int.bits,
            .Float => |float| float.bits,
            else => unreachable,
        };

        pub fn from(in: DataType) Self {
            return Self{
                .data = in,
            };
        }

        pub fn zero() Self {
            return Self{
                .data = [_]Element{0} ** len,
            };
        }

        pub fn right() Self {
            comptime if (len != 3) {
                @compileError("Vector must have three elements");
            };

            return Self{
                .data = .{ 1, 0, 0 },
            };
        }

        pub fn left() Self {
            comptime if (len != 3) {
                @compileError("Vector must have three elements");
            };

            return Self{
                .data = .{ -1, 0, 0 },
            };
        }

        pub fn up() Self {
            comptime if (len != 3) {
                @compileError("Vector must have three elements");
            };

            return Self{
                .data = .{ 0, 1, 0 },
            };
        }

        pub fn down() Self {
            comptime if (len != 3) {
                @compileError("Vector must have three elements");
            };

            return Self{
                .data = .{ 0, -1, 0 },
            };
        }

        pub fn forward() Self {
            comptime if (len != 3) {
                @compileError("Vector must have three elements");
            };

            return Self{
                .data = .{ 0, 0, 1 },
            };
        }

        pub fn back() Self {
            comptime if (len != 3) {
                @compileError("Vector must have three elements");
            };

            return Self{
                .data = .{ 0, 0, -1 },
            };
        }

        pub fn x(self: Self) Element {
            if (len < 1) {
                @compileError("len must be at least 1 to get x component");
            }

            return self.data[0];
        }

        pub fn y(self: Self) Element {
            if (len < 2) {
                @compileError("len must be at least 2 to get y component");
            }

            return self.data[1];
        }

        pub fn z(self: Self) Element {
            if (len < 3) {
                @compileError("len must be at least 3 to get z component");
            }

            return self.data[2];
        }

        pub fn w(self: Self) Element {
            if (len < 4) {
                @compileError("len must be at least 4 to get w component");
            }

            return self.data[3];
        }

        pub fn add(lhs: Self, rhs: Self) Self {
            var result = Self.zero();
            inline for (0..len) |i| {
                result.data[i] = lhs.data[i] + rhs.data[i];
            }
            return result;
        }

        pub fn sub(lhs: Self, rhs: Self) Self {
            var result = Self.zero();
            inline for (0..len) |i| {
                result.data[i] = lhs.data[i] - rhs.data[i];
            }
            return result;
        }

        pub fn neg(self: Self) Self {
            var result = self;
            inline for (0..len) |i| {
                result.data[i] = -self.data[i];
            }
            return result;
        }

        pub inline fn scale(self: Self, scalar: Element) Self {
            var result = Self.zero();
            inline for (0..len) |i| {
                result.data[i] = self.data[i] * scalar;
            }
            return result;
        }

        pub fn squareLength(self: Self) Float(precision) {
            var l: Float(precision) = 0.0;
            inline for (0..len) |i| {
                l += self.data[i] * self.data[i];
            }
            return l;
        }

        /// Returns the length or norm of a vector
        pub fn length(self: Self) Float(precision) {
            return @sqrt(self.squareLength());
        }

        /// Returns the unit vector with the same direction as `self`
        pub fn normalized(self: Self) Vec(len, Float(precision)) {
            const norm = self.length();
            if (len == 0.0) return Vec(len, Float(precision)).zero();

            return self.scale(1.0 / norm);
        }

        /// Returns the dot product of `lhs` and `rhs`
        pub fn dot(lhs: Self, rhs: Self) Element {
            var d: Element = 0.0;
            inline for (0..len) |i| {
                d += lhs.data[i] * rhs.data[i];
            }
            return d;
        }

        /// Returns the cross product of `lhs` and `rhs` in a right-handed coordinate system
        pub fn cross(lhs: Vec(3, Element), rhs: Vec(3, Element)) Vec(3, Element) {
            if (len != 3) {
                @compileError("Vector parameters must have three elements for cross() to be defined");
            }

            return Vec(3, Element){
                .data = .{
                    lhs.y() * rhs.z() - lhs.z() * rhs.y(),
                    lhs.z() * rhs.x() - lhs.x() * rhs.z(),
                    lhs.x() * rhs.y() - lhs.y() * rhs.x(),
                },
            };
        }

        /// Returns the distance between two vectors
        pub fn distance(a: Self, b: Self) Float(precision) {
            return b.sub(a).length();
        }

        /// Returns the angle (in radians) between two vectors
        pub fn angle(a: Self, b: Self) Float(precision) {
            switch (type_info) {
                .Float => {
                    const dot_product = a.dot(b);
                    return std.math.acos(dot_product / (a.length() * b.length()));
                },
                .Int => {
                    const fa = Vec(len, Float(precision)).from(@floatFromInt(a.data));
                    const fb = Vec(len, Float(precision)).from(@floatFromInt(b.data));

                    const dot_product = fa.dot(fb);
                    return std.math.acos(dot_product / (fa.length() * fb.length()));
                },
                else => unreachable,
            }
        }

        /// No extrapolation. Clamps `t`.
        ///
        /// `t` must be `.Float`.
        pub fn lerp(a: Self, b: Self, t: Float(precision)) Self {
            var result = Self.zero();
            inline for (0..len) |i| {
                result.data[i] = root.lerp(a.data[i], b.data[i], t);
            }
            return result;
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
        //     try writer.print("(" ++ ("{d}, " ** len) ++ ")", .{});
        // }
    };
}
