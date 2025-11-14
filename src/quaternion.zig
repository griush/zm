const vec = @import("vec.zig");
const mat = @import("matrix.zig");

const std = @import("std");

const EulerOrder = @import("zm.zig").EulerOrder;
const FrameConvention = @import("zm.zig").FrameConvention;

pub fn Quaternion(comptime T: type) type {
    const type_info = @typeInfo(T);
    switch (type_info) {
        .float => {},
        else => @compileError("QuaternionBase is only defined for floating point types. Type '" ++ @typeName(T) ++ "' is not supported"),
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

        pub inline fn init(w: T, x: T, y: T, z: T) Self {
            return Self{
                .w = w,
                .x = x,
                .y = y,
                .z = z,
            };
        }

        pub fn fromVec3(w: T, axis: vec.Vec(3, T)) Self {
            return Self.init(w, axis.data[0], axis.data[1], axis.data[2]);
        }

        /// `angle` takes in radians
        pub fn fromAxisAngleRH(axis: vec.Vec(3, T), radians: T) Self {
            const sin_half_angle = @sin(radians / 2);
            const w = @cos(radians / 2);
            return Self.fromVec3(w, axis.norm().scale(sin_half_angle));
        }

        /// `angle` takes in radians
        pub fn fromAxisAngleLH(axis: vec.Vec(3, T), radians: T) Self {
            const sin_half_angle = @sin(-radians / 2);
            const w = @cos(-radians / 2);
            return Self.fromVec3(w, axis.norm().scale(sin_half_angle));
        }

        pub fn fromEulerAnglesRH(v: vec.Vec(3, T), order: EulerOrder, frame: FrameConvention) Self {
            const x = Self.fromAxisAngleRH(vec.Vec(3, T){ .data = .{ 1, 0, 0 } }, v.data[0]);
            const y = Self.fromAxisAngleRH(vec.Vec(3, T){ .data = .{ 0, 1, 0 } }, v.data[1]);
            const z = Self.fromAxisAngleRH(vec.Vec(3, T){ .data = .{ 0, 0, 1 } }, v.data[2]);

            const composed = switch (order) {
                .xyz => x.multiply(y).multiply(z),
                .xzy => x.multiply(z).multiply(y),
                .yxz => y.multiply(x).multiply(z),
                .yzx => y.multiply(z).multiply(x),
                .zxy => z.multiply(x).multiply(y),
                .zyx => z.multiply(y).multiply(x),
            };

            return switch (frame) {
                .intrinsic => composed,
                .extrinsic => composed.conjugate(),
            };
        }

        pub fn fromEulerAnglesLH(v: vec.Vec(3, T), order: EulerOrder, frame: FrameConvention) Self {
            const x = Self.fromAxisAngleLH(vec.Vec(3, T){ .data = .{ 1, 0, 0 } }, v.data[0]);
            const y = Self.fromAxisAngleLH(vec.Vec(3, T){ .data = .{ 0, 1, 0 } }, v.data[1]);
            const z = Self.fromAxisAngleLH(vec.Vec(3, T){ .data = .{ 0, 0, 1 } }, v.data[2]);

            const composed = switch (order) {
                .xyz => x.multiply(y).multiply(z),
                .xzy => x.multiply(z).multiply(y),
                .yxz => y.multiply(x).multiply(z),
                .yzx => y.multiply(z).multiply(x),
                .zxy => z.multiply(x).multiply(y),
                .zyx => z.multiply(y).multiply(x),
            };

            return switch (frame) {
                .intrinsic => composed,
                .extrinsic => composed.conjugate(),
            };
        }

        pub fn fromMat3(m: mat.Mat(3, 3, T)) Self {
            // https://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/
            const trace = m.trace();
            var q: Self = undefined;

            if (trace > 0) {
                const s = @sqrt(trace + 1.0) * 2.0;
                q.w = 0.25 * s;
                q.x = (m.data[2][1] - m.data[1][2]) / s;
                q.y = (m.data[0][2] - m.data[2][0]) / s;
                q.z = (m.data[1][0] - m.data[0][1]) / s;
            } else if (m.data[0][0] > m.data[1][1] and m.data[0][0] > m.data[2][2]) {
                const s = @sqrt(1.0 + m.data[0][0] - m.data[1][1] - m.data[2][2]) * 2.0;
                q.w = (m.data[2][1] - m.data[1][2]) / s;
                q.x = 0.25 * s;
                q.y = (m.data[0][1] + m.data[1][0]) / s;
                q.z = (m.data[0][2] + m.data[2][0]) / s;
            } else if (m.data[1][1] > m.data[2][2]) {
                const s = @sqrt(1.0 + m.data[1][1] - m.data[0][0] - m.data[2][2]) * 2.0;
                q.w = (m.data[0][2] - m.data[2][0]) / s;
                q.x = (m.data[0][1] + m.data[1][0]) / s;
                q.y = 0.25 * s;
                q.z = (m.data[1][2] + m.data[2][1]) / s;
            } else {
                const s = @sqrt(1.0 + m.data[2][2] - m.data[0][0] - m.data[1][1]) * 2.0;
                q.w = (m.data[1][0] - m.data[0][1]) / s;
                q.x = (m.data[0][2] + m.data[2][0]) / s;
                q.y = (m.data[1][2] + m.data[2][1]) / s;
                q.z = 0.25 * s;
            }

            return q;
        }

        pub fn fromMat4(m: mat.Mat(4, 4, T)) Self {
            // https://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/
            const trace = m.data[0][0] + m.data[1][1] + m.data[2][2];
            var q: Self = undefined;

            if (trace > 0) {
                const s = @sqrt(trace + 1.0) * 2.0;
                q.w = 0.25 * s;
                q.x = (m.data[2][1] - m.data[1][2]) / s;
                q.y = (m.data[0][2] - m.data[2][0]) / s;
                q.z = (m.data[1][0] - m.data[0][1]) / s;
            } else if (m.data[0][0] > m.data[1][1] and m.data[0][0] > m.data[2][2]) {
                const s = @sqrt(1.0 + m.data[0][0] - m.data[1][1] - m.data[2][2]) * 2.0;
                q.w = (m.data[2][1] - m.data[1][2]) / s;
                q.x = 0.25 * s;
                q.y = (m.data[0][1] + m.data[1][0]) / s;
                q.z = (m.data[0][2] + m.data[2][0]) / s;
            } else if (m.data[1][1] > m.data[2][2]) {
                const s = @sqrt(1.0 + m.data[1][1] - m.data[0][0] - m.data[2][2]) * 2.0;
                q.w = (m.data[0][2] - m.data[2][0]) / s;
                q.x = (m.data[0][1] + m.data[1][0]) / s;
                q.y = 0.25 * s;
                q.z = (m.data[1][2] + m.data[2][1]) / s;
            } else {
                const s = @sqrt(1.0 + m.data[2][2] - m.data[0][0] - m.data[1][1]) * 2.0;
                q.w = (m.data[1][0] - m.data[0][1]) / s;
                q.x = (m.data[0][2] + m.data[2][0]) / s;
                q.y = (m.data[1][2] + m.data[2][1]) / s;
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
        pub fn scale(self: Self, scalar: T) Self {
            return Self.init(self.w * scalar, self.x * scalar, self.y * scalar, self.z * scalar);
        }

        /// Mutable scale function
        pub fn scaleAssign(self: *Self, scalar: T) Self {
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

        pub fn dot(lhs: Self, rhs: Self) T {
            return lhs.w * rhs.w + lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z;
        }

        /// No extrapolation. Clamps `t`.
        pub fn lerp(a: Self, b: Self, t: T) Self {
            const w = std.math.lerp(a.w, b.w, t);
            const x = std.math.lerp(a.x, b.x, t);
            const y = std.math.lerp(a.y, b.y, t);
            const z = std.math.lerp(a.z, b.z, t);

            return Self.init(w, x, y, z);
        }

        /// No extrapolation. Clamps `t`.
        /// Implementation from: https://gitlab.com/bztsrc/slerp-opt/-/blob/master/slerp_cross.c
        pub fn slerp(qa: Self, qb: Self, t: T) Self {
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
