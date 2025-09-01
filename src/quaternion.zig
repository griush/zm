const vec = @import("vec.zig");
const mat = @import("matrix.zig");

const std = @import("std");

pub fn Quaternion(comptime Element: type) type {
    const type_info = @typeInfo(Element);
    switch (type_info) {
        .float => {},
        else => @compileError("QuaternionBase is only defined for floating point types. Type '" ++ @typeName(Element) ++ "' is not supported"),
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

        pub inline fn init(w: Element, x: Element, y: Element, z: Element) Self {
            return Self{
                .w = w,
                .x = x,
                .y = y,
                .z = z,
            };
        }

        pub fn fromVec3(w: Element, axis: vec.Vec(3, Element)) Self {
            return Self.init(w, axis.data[0], axis.data[1], axis.data[2]);
        }

        /// `angle` takes in radians
        pub fn fromAxisAngle(axis: vec.Vec(3, Element), radians: Element) Self {
            const sin_half_angle = @sin(radians / 2);
            const w = @cos(radians / 2);
            return Self.fromVec3(w, axis.norm().scale(sin_half_angle));
        }

        /// `v` components take in radians
        pub fn fromEulerAngles(v: vec.Vec(3, Element)) Self {
            // TODO axis convention agnostic
            const x = Self.fromAxisAngle(vec.Vec(3, Element){ .data = .{ 1, 0, 0 } }, v.data[0]);
            const y = Self.fromAxisAngle(vec.Vec(3, Element){ .data = .{ 0, 1, 0 } }, v.data[1]);
            const z = Self.fromAxisAngle(vec.Vec(3, Element){ .data = .{ 0, 0, 1 } }, v.data[2]);

            return z.multiply(y.multiply(x));
        }

        pub fn fromMat3(m: mat.Mat3Base(Element)) Self {
            // https://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/
            const trace = m.data[0 * 3 + 0] + m.data[1 * 3 + 1] + m.data[2 * 3 + 2];
            var q: Self = undefined;
            if (trace > 0) {
                const s = @sqrt(trace + 1.0) * 2.0;
                q.w = 0.25 * s;
                q.x = (m.data[2 * 3 + 1] - m.data[1 * 3 + 2]) / s;
                q.y = (m.data[0 * 3 + 2] - m.data[2 * 3 + 0]) / s;
                q.z = (m.data[1 * 3 + 0] - m.data[0 * 3 + 1]) / s;
            } else if (m.data[0 * 3 + 0] > m.data[1 * 3 + 1] and m.data[0 * 3 + 0] > m.data[2 * 3 + 2]) {
                const s = @sqrt(1.0 + m.data[0 * 3 + 0] - m.data[1 * 3 + 1] - m.data[2 * 3 + 2]) * 2.0;
                q.w = (m.data[2 * 3 + 1] - m.data[1 * 3 + 2]) / s;
                q.x = 0.25 * s;
                q.y = (m.data[0 * 3 + 1] + m.data[1 * 3 + 0]) / s;
                q.z = (m.data[0 * 3 + 2] + m.data[2 * 3 + 0]) / s;
            } else if (m.data[1 * 3 + 1] > m.data[2 * 3 + 2]) {
                const s = @sqrt(1.0 + m.data[1 * 3 + 1] - m.data[0 * 3 + 0] - m.data[2 * 3 + 2]) * 2.0;
                q.w = (m.data[0 * 3 + 2] - m.data[2 * 3 + 0]) / s;
                q.x = (m.data[0 * 3 + 1] + m.data[1 * 3 + 0]) / s;
                q.y = 0.25 * s;
                q.z = (m.data[1 * 3 + 2] + m.data[2 * 3 + 1]) / s;
            } else {
                const s = @sqrt(1.0 + m.data[2 * 3 + 2] - m.data[0 * 3 + 0] - m.data[1 * 3 + 1]) * 2.0;
                q.w = (m.data[1 * 3 + 0] - m.data[0 * 3 + 1]) / s;
                q.x = (m.data[0 * 3 + 2] + m.data[2 * 3 + 0]) / s;
                q.y = (m.data[1 * 3 + 2] + m.data[2 * 3 + 1]) / s;
                q.z = 0.25 * s;
            }
            return q;
        }

        pub fn fromMat4(m: mat.Mat4Base(Element)) Self {
            // https://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/
            const trace = m.data[0 * 4 + 0] + m.data[1 * 4 + 1] + m.data[2 * 4 + 2];
            var q: Self = undefined;
            if (trace > 0) {
                const s = @sqrt(trace + 1.0) * 2.0;
                q.w = 0.25 * s;
                q.x = (m.data[2 * 4 + 1] - m.data[1 * 4 + 2]) / s;
                q.y = (m.data[0 * 4 + 2] - m.data[2 * 4 + 0]) / s;
                q.z = (m.data[1 * 4 + 0] - m.data[0 * 4 + 1]) / s;
            } else if (m.data[0 * 4 + 0] > m.data[1 * 4 + 1] and m.data[0 * 4 + 0] > m.data[2 * 4 + 2]) {
                const s = @sqrt(1.0 + m.data[0 * 4 + 0] - m.data[1 * 4 + 1] - m.data[2 * 4 + 2]) * 2.0;
                q.w = (m.data[2 * 4 + 1] - m.data[1 * 4 + 2]) / s;
                q.x = 0.25 * s;
                q.y = (m.data[0 * 4 + 1] + m.data[1 * 4 + 0]) / s;
                q.z = (m.data[0 * 4 + 2] + m.data[2 * 4 + 0]) / s;
            } else if (m.data[1 * 4 + 1] > m.data[2 * 4 + 2]) {
                const s = @sqrt(1.0 + m.data[1 * 4 + 1] - m.data[0 * 4 + 0] - m.data[2 * 4 + 2]) * 2.0;
                q.w = (m.data[0 * 4 + 2] - m.data[2 * 4 + 0]) / s;
                q.x = (m.data[0 * 4 + 1] + m.data[1 * 4 + 0]) / s;
                q.y = 0.25 * s;
                q.z = (m.data[1 * 4 + 2] + m.data[2 * 4 + 1]) / s;
            } else {
                const s = @sqrt(1.0 + m.data[2 * 4 + 2] - m.data[0 * 4 + 0] - m.data[1 * 4 + 1]) * 2.0;
                q.w = (m.data[1 * 4 + 0] - m.data[0 * 4 + 1]) / s;
                q.x = (m.data[0 * 4 + 2] + m.data[2 * 4 + 0]) / s;
                q.y = (m.data[1 * 4 + 2] + m.data[2 * 4 + 1]) / s;
                q.z = 0.25 * s;
            }
            return q;
        }

        pub fn add(lhs: Self, rhs: Self) Self {
            return Self.init(lhs.w + rhs.w, lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z);
        }

        pub fn sub(lhs: Self, rhs: Self) Self {
            return Self.init(lhs.w - rhs.w, lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z);
        }

        /// Non-mutable scale function
        pub fn scale(self: Self, scalar: Element) Self {
            return Self.init(self.w * scalar, self.x * scalar, self.y * scalar, self.z * scalar);
        }

        /// Mutable scale function
        pub fn scaleAssign(self: *Self, scalar: Element) Self {
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
            return Self.init(self.w, -self.x, -self.y, -self.z);
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
            const w = std.math.lerp(a.w, b.w, t);
            const x = std.math.lerp(a.x, b.x, t);
            const y = std.math.lerp(a.y, b.y, t);
            const z = std.math.lerp(a.z, b.z, t);

            return Self.init(w, x, y, z);
        }

        /// No extrapolation. Clamps `t`.
        /// Implementation from: https://gitlab.com/bztsrc/slerp-opt/-/blob/master/slerp_cross.c
        pub fn slerp(qa: Self, qb: Self, t: Element) Self {
            var a = 1.0 - t;
            var b = t;
            const d = qa.w * qb.w + qa.x * qb.x + qa.y * qb.y + qa.z * qb.z;
            var c = @abs(d);

            if (c < 0.999) {
                c = std.math.acos(c);
                b = 1 / @sin(c);
                a = @sin(a * c) * b;
                b *= @sin(t * c);
                if (d < 0) b = -b;
            }

            return Self.init(qa.w * a + qb.w * b, qa.x * a + qb.x * b, qa.y * a + qb.y * b, qa.z * a + qb.z * b);
        }
    };
}
