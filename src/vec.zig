const math = @import("std").math;

pub fn Vec(n: comptime_int, comptime T: type) type {
    if (n < 1) {
        @compileError("Vec of 0 or negative dimension is not allowed");
    }

    const type_info = @typeInfo(T);
    comptime switch (type_info) {
        .float => {},
        else => @compileError("Vec is not implemented for type " ++ @typeName(T)),
    };

    return struct {
        const Self = @This();

        data: [n]T,

        pub fn zero() Self {
            return Self{ .data = @splat(0) };
        }

        pub fn init(v: T) Self {
            return Self{ .data = @splat(v) };
        }

        pub fn add(self: Self, other: Self) Self {
            var result: Self = .{ .data = undefined };
            inline for (0..n) |i| {
                result.data[i] = self.data[i] + other.data[i];
            }
            return result;
        }

        pub fn addAssign(self: *Self, other: Self) void {
            inline for (0..n) |i| {
                self.data[i] += other.data[i];
            }
        }

        pub fn sub(self: Self, other: Self) Self {
            var result: Self = .{ .data = undefined };
            inline for (0..n) |i| {
                result.data[i] = self.data[i] - other.data[i];
            }
            return result;
        }

        pub fn subAssign(self: *Self, other: Self) void {
            inline for (0..n) |i| {
                self.data[i] -= other.data[i];
            }
        }

        pub fn scale(self: Self, other: T) Self {
            var result: Self = .{ .data = undefined };
            inline for (0..n) |i| {
                result.data[i] = self.data[i] * other;
            }
            return result;
        }

        pub fn scaleAssign(self: *Self, other: T) void {
            inline for (0..n) |i| {
                self.data[i] *= other;
            }
        }

        pub fn dot(self: Self, other: Self) T {
            var sum: T = 0;
            inline for (0..n) |i| {
                sum += self.data[i] * other.data[i];
            }
            return sum;
        }

        pub fn mul(self: Self, other: Self) Self {
            var result: Self = .{ .data = undefined };
            inline for (0..n) |i| {
                result.data[i] = self.data[i] * other.data[i];
            }
            return result;
        }

        pub fn mulAssign(self: *Self, other: Self) void {
            inline for (0..n) |i| {
                self.data[i] *= other.data[i];
            }
        }

        pub fn lenSq(self: Self) T {
            return self.dot(self);
        }

        pub fn len(self: Self) T {
            return @sqrt(self.lenSq());
        }

        pub fn norm(self: Self) Self {
            const magnitude = self.len();
            if (magnitude == 0.0) {
                @panic("cannot normalize zero vector");
            }
            var result: Self = .{ .data = undefined };
            inline for (0..n) |i| {
                result.data[i] = self.data[i] / magnitude;
            }
            return result;
        }

        pub fn distance(self: Self, other: Self) T {
            var sum: T = 0;
            inline for (0..n) |i| {
                const diff = self.data[i] - other.data[i];
                sum += diff * diff;
            }
            return @sqrt(sum);
        }

        pub fn angle(a: Self, b: Self) T {
            const d = a.dot(b);
            const mag = a.len() * b.len();
            return math.acos(d / mag);
        }

        /// Extrapolates if `t` is outside of 0..1 range
        pub fn lerp(a: Self, b: Self, t: T) Self {
            var result: Self = .{ .data = undefined };
            inline for (0..n) |i| {
                result.data[i] = @mulAdd(T, b.data[i] - a.data[i], t, a.data[i]);
            }
            return result;
        }

        /// Extrapolates if `t` is outside of 0..1 range
        pub fn lerpAssign(self: *Self, b: Self, t: T) void {
            inline for (0..n) |i| {
                self.data[i] = @mulAdd(T, b.data[i] - self.data[i], t, self.data[i]);
            }
        }

        /// Reflects `self` along `normal`. `normal` must be normalized.
        pub fn reflect(self: Self, normal: Self) Self {
            const dot_val = self.dot(normal);
            var result: Self = .{ .data = undefined };
            inline for (0..n) |i| {
                result.data[i] = self.data[i] - 2 * dot_val * normal.data[i];
            }
            return result;
        }

        /// Right-handed cross product
        pub fn crossRH(self: Self, b: Self) Self {
            comptime {
                if (n != 3) {
                    @compileError("crossRH is only defined for 3 dimensional vectors");
                }
            }

            return Self{ .data = .{
                self.data[1] * b.data[2] - self.data[2] * b.data[1],
                self.data[2] * b.data[0] - self.data[0] * b.data[2],
                self.data[0] * b.data[1] - self.data[1] * b.data[0],
            } };
        }

        /// Left-handed cross product
        pub fn crossLH(self: Self, b: Self) Self {
            comptime {
                if (n != 3) {
                    @compileError("crossLH is only defined for 3 dimensional vectors");
                }
            }

            // simply flip the sign of the RH result
            const cr = crossRH(self, b);
            return Self{ .data = .{ -cr.data[0], -cr.data[1], -cr.data[2] } };
        }
    };
}

pub const Vec2f = Vec(2, f32);
pub const Vec3f = Vec(3, f32);
pub const Vec4f = Vec(4, f32);
pub const Vec2 = Vec(2, f64);
pub const Vec3 = Vec(3, f64);
pub const Vec4 = Vec(4, f64);
