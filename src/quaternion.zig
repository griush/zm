const Vec = @import("vector.zig").Vec;
const clamp = @import("root.zig").clamp;
const lerp = @import("root.zig").lerp;

const std = @import("std");

const root = @This();

pub fn QuaternionBase(comptime T: type) type {
    const type_info = @typeInfo(T);
    switch (type_info) {
        .Float => {},
        else => @compileError("QuaternionBase only supports floating point types. Type '" ++ @typeName(T) ++ "' is not supported"),
    }

    return struct {
        const Self = @This();

        // Data
        w: T,
        x: T,
        y: T,
        z: T,

        pub inline fn identity() Self {
            return Self{
                .w = 1.0,
                .x = 0.0,
                .y = 0.0,
                .z = 0.0,
            };
        }

        pub inline fn from(w: T, x: T, y: T, z: T) Self {
            return Self{
                .w = w,
                .x = x,
                .y = y,
                .z = z,
            };
        }

        pub fn fromVec3(w: T, axis: Vec(3, T)) Self {
            return Self.from(w, axis.x(), axis.y(), axis.z());
        }

        /// `angle` takes in radians
        pub fn fromAxisAngle(axis: Vec(3, T), radians: T) Self {
            const sin_half_angle = @sin(radians / 2);
            const w = @cos(radians / 2);
            return Self.fromVec3(w, axis.normalized().scale(sin_half_angle));
        }

        /// `v` components take in radians
        pub fn fromEulerAngles(v: Vec(3, T)) Self {
            const x = Self.fromAxisAngle(Vec(3, T).right(), v.x());
            const y = Self.fromAxisAngle(Vec(3, T).up(), v.y());
            const z = Self.fromAxisAngle(Vec(3, T).forward(), v.z());

            return z.multiply(y.multiply(x));
        }

        // TODO: Constructor from rotation matrix

        pub fn add(self: Self, other: Self) Self {
            return Self.from(self.w + other.w, self.x + other.x, self.y + other.y, self.z + other.z);
        }

        pub fn sub(self: Self, other: Self) Self {
            return Self.from(self.w - other.w, self.x - other.x, self.y - other.y, self.z - other.z);
        }

        /// Non-mutable scale function
        pub fn scale(self: Self, scalar: T) Self {
            return Self.from(self.w * scalar, self.x * scalar, self.y * scalar, self.z * scalar);
        }

        /// Mutable scale function
        pub fn scaleMut(self: *Self, scalar: T) Self {
            self.w *= scalar;
            self.x *= scalar;
            self.y *= scalar;
            self.z *= scalar;

            return self.*;
        }

        pub fn neg(self: Self) Self {
            return self.scale(-1.0);
        }

        pub fn normalize(self: *Self) void {
            const m = @sqrt(self.w * self.w + self.x * self.x + self.y * self.y + self.z * self.z);
            if (m > 0.0) {
                const i_m = 1.0 / m;
                self.w *= i_m;
                self.x *= i_m;
                self.y *= i_m;
                self.z *= i_m;
            } else {
                self.* = Self.identity();
            }
        }

        pub inline fn conjugate(self: Self) Self {
            return Self.from(self.w, -self.x, -self.y, -self.z);
        }

        pub fn multiply(self: Self, other: Self) Self {
            return Self{
                .w = self.w * other.w - self.x * other.x - self.y * other.y - self.z * other.z,
                .x = self.w * other.x + self.x * other.w + self.y * other.z - self.z * other.y,
                .y = self.w * other.y - self.x * other.z + self.y * other.w + self.z * other.x,
                .z = self.w * other.z + self.x * other.y - self.y * other.x + self.z * other.w,
            };
        }

        pub fn inverse(self: Self) Self {
            const norm_sq = self.w * self.w + self.x * self.x + self.y * self.y + self.z * self.z;
            if (norm_sq == 0) {
                return Self.identity();
            }
            const inv_norm_sq = 1.0 / norm_sq;
            return Self{
                .w = self.w * inv_norm_sq,
                .x = -self.x * inv_norm_sq,
                .y = -self.y * inv_norm_sq,
                .z = -self.z * inv_norm_sq,
            };
        }

        pub fn dot(left: Self, right: Self) T {
            return left.w * right.w + left.x * right.x + left.y * right.y + left.z * right.z;
        }

        /// No extrapolation. Clamps `t`.
        pub fn lerp(self: Self, other: Self, t: T) Self {
            const w = root.lerp(self.w, other.w, t);
            const x = root.lerp(self.x, other.x, t);
            const y = root.lerp(self.y, other.y, t);
            const z = root.lerp(self.z, other.z, t);

            return Self.from(w, x, y, z);
        }

        /// No extrapolation. Clamps `t`.
        pub fn slerp(a: Self, b: Self, t: T) Self {
            // TODO: Look at https://gitlab.com/bztsrc/slerp-opt
            // and implement fastSlerp
            const tc = clamp(t, 0.0, 1.0);
            var am = a;
            var cos_theta = am.dot(b);

            if (cos_theta <= 0.0) {
                _ = am.scaleMut(-1);
                cos_theta = -cos_theta;
            }

            if (cos_theta > 0.9995) {
                // If mostly identical, lerp
                var result = Self.lerp(am, b, tc);
                result.normalize();
                return result;
            }

            const theta = std.math.acos(root.clamp(cos_theta, -1, 1));
            const denominator: T = @sin(theta);
            const pt = (1.0 - t) * theta;
            const spt = @sin(pt);
            const sptp = am.scale(spt);

            const sqt = @sin(tc * theta);
            const sqtq = b.scale(sqt);

            const numerator = sptp.add(sqtq);

            return numerator.scale(1.0 / denominator);
        }

        /// This function allows `Quaternion`s to be formated by Zig's `std.fmt`.
        /// Example: `std.debug.print("Vec: {any}", .{ zm.Quaternion.fromEulerAngles(zm.Vec3.up()) });`
        pub fn format(
            q: Self,
            comptime fmt: []const u8,
            options: std.fmt.FormatOptions,
            writer: anytype,
        ) !void {
            _ = fmt;
            _ = options;

            try writer.print("(w: {d}, v: ({d}, {d}, {d}))", .{
                q.w,
                q.x,
                q.y,
                q.z,
            });
        }
    };
}
