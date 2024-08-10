const Vec = @import("vector.zig").Vec;
const clamp = @import("zm.zig").clamp;
const lerp = @import("zm.zig").lerp;

const std = @import("std");

const root = @This();

pub fn QuaternionBase(comptime Element: type) type {
    const type_info = @typeInfo(Element);
    switch (type_info) {
        .Float => {},
        else => @compileError("QuaternionBase only supports floating point types. Type '" ++ @typeName(Element) ++ "' is not supported"),
    }

    return struct {
        const Self = @This();

        // Data
        w: Element,
        x: Element,
        y: Element,
        z: Element,

        pub inline fn identity() Self {
            return Self{
                .w = 1.0,
                .x = 0.0,
                .y = 0.0,
                .z = 0.0,
            };
        }

        pub inline fn from(w: Element, x: Element, y: Element, z: Element) Self {
            return Self{
                .w = w,
                .x = x,
                .y = y,
                .z = z,
            };
        }

        pub fn fromVec3(w: Element, axis: Vec(3, Element)) Self {
            return Self.from(w, axis.x(), axis.y(), axis.z());
        }

        /// `angle` takes in radians
        pub fn fromAxisAngle(axis: Vec(3, Element), radians: Element) Self {
            const sin_half_angle = @sin(radians / 2);
            const w = @cos(radians / 2);
            return Self.fromVec3(w, axis.normalized().scale(sin_half_angle));
        }

        /// `v` components take in radians
        pub fn fromEulerAngles(v: Vec(3, Element)) Self {
            const x = Self.fromAxisAngle(Vec(3, Element).right(), v.x());
            const y = Self.fromAxisAngle(Vec(3, Element).up(), v.y());
            const z = Self.fromAxisAngle(Vec(3, Element).forward(), v.z());

            return z.multiply(y.multiply(x));
        }

        // TODO: Constructor from rotation matrix

        pub fn add(lhs: Self, rhs: Self) Self {
            return Self.from(lhs.w + rhs.w, lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z);
        }

        pub fn sub(lhs: Self, rhs: Self) Self {
            return Self.from(lhs.w - rhs.w, lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z);
        }

        /// Non-mutable scale function
        pub fn scale(self: Self, scalar: Element) Self {
            return Self.from(self.w * scalar, self.x * scalar, self.y * scalar, self.z * scalar);
        }

        /// Mutable scale function
        pub fn scaleMut(self: *Self, scalar: Element) Self {
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

        pub fn multiply(lhs: Self, rhs: Self) Self {
            return Self{
                .w = lhs.w * rhs.w - lhs.x * rhs.x - lhs.y * rhs.y - lhs.z * rhs.z,
                .x = lhs.w * rhs.x + lhs.x * rhs.w + lhs.y * rhs.z - lhs.z * rhs.y,
                .y = lhs.w * rhs.y - lhs.x * rhs.z + lhs.y * rhs.w + lhs.z * rhs.x,
                .z = lhs.w * rhs.z + lhs.x * rhs.y - lhs.y * rhs.x + lhs.z * rhs.w,
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

        pub fn dot(lhs: Self, rhs: Self) Element {
            return lhs.w * rhs.w + lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z;
        }

        /// No extrapolation. Clamps `t`.
        pub fn lerp(a: Self, b: Self, t: Element) Self {
            const w = root.lerp(a.w, b.w, t);
            const x = root.lerp(a.x, b.x, t);
            const y = root.lerp(a.y, b.y, t);
            const z = root.lerp(a.z, b.z, t);

            return Self.from(w, x, y, z);
        }

        /// No extrapolation. Clamps `t`.
        pub fn slerp(a: Self, b: Self, t: Element) Self {
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
            const denominator: Element = @sin(theta);
            const pt = (1.0 - tc) * theta;
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
