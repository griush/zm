const math = @import("std").math;
const vec = @import("vec.zig");
const Quaternion = @import("quaternion.zig").Quaternion;

/// Row-major matrix type
pub fn Mat(r: comptime_int, c: comptime_int, comptime T: type) type {
    if (r < 1 or c < 1) {
        @compileError("Mat of 0 or negative dimension is not allowed");
    }

    const type_info = @typeInfo(T);
    comptime switch (type_info) {
        .float => {},
        else => @compileError("Mat is not implemented for type " ++ @typeName(T)),
    };

    return struct {
        const Self = @This();

        data: [r][c]T,

        pub fn rows() comptime_int {
            return r;
        }

        pub fn cols() comptime_int {
            return c;
        }

        pub fn zero() Self {
            var result: Self = undefined;
            inline for (0..r) |i| {
                inline for (0..c) |j| {
                    result.data[i][j] = 0.0;
                }
            }
            return result;
        }

        pub fn diagonal(v: T) Self {
            comptime {
                if (c != r) {
                    @compileError("Mat.diagonal constructor is only available for square matrices (rows == cols)");
                }
            }
            var result = Self.zero();
            inline for (0..r) |i| {
                result.data[i][i] = v;
            }
            return result;
        }

        pub fn identity() Self {
            comptime {
                if (c != r) {
                    @compileError("Mat.identity constructor is only available for square matrices (rows == cols)");
                }
            }
            return diagonal(1.0);
        }

        pub fn add(self: Self, other: Self) Self {
            var result: Self = undefined;
            inline for (0..r) |i| {
                inline for (0..c) |j| {
                    result.data[i][j] = self.data[i][j] + other.data[i][j];
                }
            }
            return result;
        }

        pub fn addAssign(self: *Self, other: Self) void {
            inline for (0..r) |i| {
                inline for (0..c) |j| {
                    self.data[i][j] += other.data[i][j];
                }
            }
        }

        pub fn sub(self: Self, other: Self) Self {
            var result: Self = undefined;
            inline for (0..r) |i| {
                inline for (0..c) |j| {
                    result.data[i][j] = self.data[i][j] - other.data[i][j];
                }
            }
            return result;
        }

        pub fn subAssign(self: *Self, other: Self) void {
            inline for (0..r) |i| {
                inline for (0..c) |j| {
                    self.data[i][j] -= other.data[i][j];
                }
            }
        }

        pub fn scale(self: Self, scalar: T) Self {
            var result: Self = undefined;
            inline for (0..r) |i| {
                inline for (0..c) |j| {
                    result.data[i][j] = self.data[i][j] * scalar;
                }
            }
            return result;
        }

        pub fn scaleAssign(self: *Self, scalar: T) void {
            inline for (0..r) |i| {
                inline for (0..c) |j| {
                    self.data[i][j] *= scalar;
                }
            }
        }

        pub fn transpose(self: Self) Mat(c, r, T) {
            var result: Mat(c, r, T) = undefined;
            inline for (0..r) |i| {
                inline for (0..c) |j| {
                    result.data[j][i] = self.data[i][j];
                }
            }
            return result;
        }

        pub fn multiply(self: Self, other: anytype) Mat(r, @TypeOf(other).cols(), T) {
            comptime {
                if (c != @TypeOf(other).rows()) {
                    @compileError("Cannot multiply matrices: self.cols != other.rows");
                }
            }

            const k = c;
            var result: Mat(r, @TypeOf(other).cols(), T) = Mat(r, @TypeOf(other).cols(), T).zero();

            inline for (0..r) |i| {
                inline for (0..@TypeOf(other).cols()) |j| {
                    var sum: T = 0.0;
                    inline for (0..k) |l| {
                        sum += self.data[i][l] * other.data[l][j];
                    }
                    result.data[i][j] = sum;
                }
            }
            return result;
        }

        pub fn multiplyVec(self: Self, v: vec.Vec(c, T)) vec.Vec(r, T) {
            var result: vec.Vec(r, T) = undefined;

            inline for (0..r) |i| {
                var sum: T = 0;
                inline for (0..c) |j| {
                    sum += self.data[i][j] * v.data[j];
                }
                result.data[i] = sum;
            }

            return result;
        }

        /// Returns the sum of the diagonal
        pub fn trace(self: Self) T {
            comptime {
                if (r != c) {
                    @compileError("trace is only defined for square matrices");
                }
            }

            var result: T = 0.0;
            inline for (0..c) |i| {
                result += self.data[i][i];
            }
            return result;
        }

        /// Recursive Laplace expansion. O(N!)
        pub fn determinant(self: Self) T {
            comptime {
                if (r != c) {
                    @compileError("determinant is only defined for square matrices");
                }
            }

            if (r == 1) {
                return self.data[0][0];
            } else if (r == 2) {
                return self.data[0][0] * self.data[1][1] -
                    self.data[0][1] * self.data[1][0];
            }

            var det: T = 0;
            inline for (0..c) |col| {
                const sign: T = if (col % 2 == 0) 1 else -1;
                const minor_matrix = self.minor(0, col);
                det += sign * self.data[0][col] * minor_matrix.determinant();
            }
            return det;
        }

        /// Compute the minor matrix after removing row and col
        pub fn minor(self: Self, row: usize, col: usize) Mat(r - 1, c - 1, T) {
            var result = Mat(r - 1, c - 1, T).zero();

            var rr: usize = 0;
            for (0..r) |i| {
                if (i == row) continue;
                var cc: usize = 0;
                for (0..c) |j| {
                    if (j == col) continue;
                    result.data[rr][cc] = self.data[i][j];
                    cc += 1;
                }
                rr += 1;
            }
            return result;
        }

        /// generic inverse
        pub fn inverse(self: Self) !Self {
            comptime {
                if (r != c) {
                    @compileError("inverse is only defined for square matrices");
                }
            }

            const det_val = self.determinant();
            if (det_val == 0) return error.singular;

            var cof: Self = undefined;

            inline for (0..r) |i| {
                inline for (0..c) |j| {
                    const m = self.minor(i, j);
                    const sign: T = if (((i + j) % 2) == 0) 1 else -1;
                    cof.data[i][j] = sign * m.determinant();
                }
            }

            const adj = cof.transpose();
            var inv: Self = undefined;

            inline for (0..r) |i| {
                inline for (0..c) |j| {
                    inv.data[i][j] = adj.data[i][j] / det_val;
                }
            }

            return inv;
        }

        pub fn fastInverse(self: Self) Self {
            const m = self.data;

            const t0  = m[2][2] * m[3][3];
            const t1  = m[3][2] * m[2][3];
            const t2  = m[1][2] * m[3][3];
            const t3  = m[3][2] * m[1][3];
            const t4  = m[1][2] * m[2][3];
            const t5  = m[2][2] * m[1][3];
            const t6  = m[0][2] * m[3][3];
            const t7  = m[3][2] * m[0][3];
            const t8  = m[0][2] * m[2][3];
            const t9  = m[2][2] * m[0][3];
            const t10 = m[0][2] * m[1][3];
            const t11 = m[1][2] * m[0][3];
            const t12 = m[2][0] * m[3][1];
            const t13 = m[3][0] * m[2][1];
            const t14 = m[1][0] * m[3][1];
            const t15 = m[3][0] * m[1][1];
            const t16 = m[1][0] * m[2][1];
            const t17 = m[2][0] * m[1][1];
            const t18 = m[0][0] * m[3][1];
            const t19 = m[3][0] * m[0][1];
            const t20 = m[0][0] * m[2][1];
            const t21 = m[2][0] * m[0][1];
            const t22 = m[0][0] * m[1][1];
            const t23 = m[1][0] * m[0][1];

            var result = Self.diagonal(0.0);

            result.data[0][0] = (t0 * m[1][1] + t3 * m[2][1] + t4 * m[3][1]) - (t1 * m[1][1] + t2 * m[2][1] + t5 * m[3][1]);
            result.data[0][1] = (t1 * m[0][1] + t6 * m[2][1] + t9 * m[3][1]) - (t0 * m[0][1] + t7 * m[2][1] + t8 * m[3][1]);
            result.data[0][2] = (t2 * m[0][1] + t7 * m[1][1] + t10 * m[3][1]) - (t3 * m[0][1] + t6 * m[1][1] + t11 * m[3][1]);
            result.data[0][3] = (t5 * m[0][1] + t8 * m[1][1] + t11 * m[2][1]) - (t4 * m[0][1] + t9 * m[1][1] + t10 * m[2][1]);

            const d = 1.0 / (
                m[0][0] * result.data[0][0] +
                m[1][0] * result.data[0][1] +
                m[2][0] * result.data[0][2] +
                m[3][0] * result.data[0][3]
            );

            result.data[0][0] *= d;
            result.data[0][1] *= d;
            result.data[0][2] *= d;
            result.data[0][3] *= d;

            result.data[1][0] = d * ((t1 * m[1][0] + t2 * m[2][0] + t5 * m[3][0]) - (t0 * m[1][0] + t3 * m[2][0] + t4 * m[3][0]));
            result.data[1][1] = d * ((t0 * m[0][0] + t7 * m[2][0] + t8 * m[3][0]) - (t1 * m[0][0] + t6 * m[2][0] + t9 * m[3][0]));
            result.data[1][2] = d * ((t3 * m[0][0] + t6 * m[1][0] + t11 * m[3][0]) - (t2 * m[0][0] + t7 * m[1][0] + t10 * m[3][0]));
            result.data[1][3] = d * ((t4 * m[0][0] + t9 * m[1][0] + t10 * m[2][0]) - (t5 * m[0][0] + t8 * m[1][0] + t11 * m[2][0]));

            result.data[2][0] = d * ((t12 * m[1][3] + t15 * m[2][3] + t16 * m[3][3]) - (t13 * m[1][3] + t14 * m[2][3] + t17 * m[3][3]));
            result.data[2][1] = d * ((t13 * m[0][3] + t18 * m[2][3] + t21 * m[3][3]) - (t12 * m[0][3] + t19 * m[2][3] + t20 * m[3][3]));
            result.data[2][2] = d * ((t14 * m[0][3] + t19 * m[1][3] + t22 * m[3][3]) - (t15 * m[0][3] + t18 * m[1][3] + t23 * m[3][3]));
            result.data[2][3] = d * ((t17 * m[0][3] + t20 * m[1][3] + t23 * m[2][3]) - (t16 * m[0][3] + t21 * m[1][3] + t22 * m[2][3]));

            result.data[3][0] = d * ((t14 * m[2][2] + t17 * m[3][2] + t13 * m[1][2]) - (t16 * m[3][2] + t12 * m[1][2] + t15 * m[2][2]));
            result.data[3][1] = d * ((t20 * m[3][2] + t12 * m[0][2] + t19 * m[2][2]) - (t18 * m[2][2] + t21 * m[3][2] + t13 * m[0][2]));
            result.data[3][2] = d * ((t18 * m[1][2] + t23 * m[3][2] + t15 * m[0][2]) - (t22 * m[3][2] + t14 * m[0][2] + t19 * m[1][2]));
            result.data[3][3] = d * ((t22 * m[2][2] + t16 * m[0][2] + t21 * m[1][2]) - (t20 * m[1][2] + t23 * m[2][2] + t17 * m[0][2]));

            return result;
        }

        pub fn fromQuaternion(q: Quaternion(T)) Self {
            comptime {
                if (r != 4 or c != 4) {
                    @compileError("fromQuaternion is only defined for 4x4 matrices");
                }
            }

            // From https://www.euclideanspace.com/maths/geometry/rotations/conversions/quaternionToMatrix/index.htm
            var result = Self.identity();

            // Row 0
            result.data[0][0] = 1 - 2 * q.y * q.y - 2 * q.z * q.z;
            result.data[0][1] = 2 * q.x * q.y - 2 * q.z * q.w;
            result.data[0][2] = 2 * q.x * q.z + 2 * q.y * q.w;

            // Row 1
            result.data[1][0] = 2 * q.x * q.y + 2 * q.z * q.w;
            result.data[1][1] = 1 - 2 * q.x * q.x - 2 * q.z * q.z;
            result.data[1][2] = 2 * q.y * q.z - 2 * q.x * q.w;

            // Row 2
            result.data[2][0] = 2 * q.x * q.z - 2 * q.y * q.w;
            result.data[2][1] = 2 * q.y * q.z + 2 * q.x * q.w;
            result.data[2][2] = 1 - 2 * q.x * q.x - 2 * q.y * q.y;

            return result;
        }

        /// Right-handed lookAt matrix
        pub fn lookAtRH(eye: vec.Vec(3, T), target: vec.Vec(3, T), up: vec.Vec(3, T)) Self {
            comptime {
                if (r != 4 or c != 4) {
                    @compileError("lookAtRH is only defined for 4x4 matrices");
                }
            }

            const f = target.sub(eye).norm();
            const s = f.crossRH(up).norm();
            const u = s.crossRH(f).norm();

            return Self{
                .data = .{
                    .{ s.data[0], s.data[1], s.data[2], -s.dot(eye) },
                    .{ u.data[0], u.data[1], u.data[2], -u.dot(eye) },
                    .{ -f.data[0], -f.data[1], -f.data[2], f.dot(eye) },
                    .{ 0, 0, 0, 1 },
                },
            };
        }

        /// Left-handed lookAt matrix
        pub fn lookAtLH(eye: vec.Vec(3, T), target: vec.Vec(3, T), up: vec.Vec(3, T)) Self {
            comptime {
                if (r != 4 or c != 4) {
                    @compileError("lookAtLH is only defined for 4x4 matrices");
                }
            }

            const f = target.sub(eye).norm();
            const s = f.crossLH(up).norm();
            const u = s.crossLH(f).norm();

            return Self{
                .data = .{
                    .{ s.data[0], s.data[1], s.data[2], -s.dot(eye) },
                    .{ u.data[0], u.data[1], u.data[2], -u.dot(eye) },
                    .{ f.data[0], f.data[1], f.data[2], -f.dot(eye) },
                    .{ 0, 0, 0, 1 },
                },
            };
        }

        /// Right-handed orthographic projection
        pub fn orthographicRH(left: T, right: T, bottom: T, top: T, near: T, far: T) Self {
            comptime {
                if (r != 4 or c != 4) {
                    @compileError("orthographicRH is only defined for 4x4 matrices");
                }
            }

            const rl = right - left;
            const tb = top - bottom;
            const fnf = far - near;

            return Self{
                .data = .{
                    .{ 2 / rl, 0, 0, -(right + left) / rl },
                    .{ 0, 2 / tb, 0, -(top + bottom) / tb },
                    .{ 0, 0, -2 / fnf, -(far + near) / fnf },
                    .{ 0, 0, 0, 1 },
                },
            };
        }

        /// Left-handed orthographic projection
        pub fn orthographicLH(left: T, right: T, bottom: T, top: T, near: T, far: T) Self {
            comptime {
                if (r != 4 or c != 4) {
                    @compileError("orthographicLH is only defined for 4x4 matrices");
                }
            }

            const rl = right - left;
            const tb = top - bottom;
            const fnf = far - near;

            return Self{
                .data = .{
                    .{ 2 / rl, 0, 0, -(right + left) / rl },
                    .{ 0, 2 / tb, 0, -(top + bottom) / tb },
                    .{ 0, 0, 2 / fnf, -(far + near) / fnf },
                    .{ 0, 0, 0, 1 },
                },
            };
        }

        /// Right-handed perspective projection (OpenGL-style: Z ∈ [-1,1]).
        ///
        /// `fov` in radians
        pub fn perspectiveRH(fov: T, aspect: T, near: T, far: T) Self {
            comptime {
                if (r != 4 or c != 4) {
                    @compileError("perspectiveRH is only defined for 4x4 matrices");
                }
            }

            const f = 1 / math.tan(fov / 2);
            const fnf = far - near;

            return Self{
                .data = .{
                    .{ f / aspect, 0, 0, 0 },
                    .{ 0, f, 0, 0 },
                    .{ 0, 0, -(far + near) / fnf, -(2 * far * near) / fnf },
                    .{ 0, 0, -1, 0 },
                },
            };
        }

        /// Left-handed perspective projection
        ///
        /// `fov` in radians
        pub fn perspectiveLH(fov: T, aspect: T, near: T, far: T) Self {
            comptime {
                if (r != 4 or c != 4) {
                    @compileError("perspectiveLH is only defined for 4x4 matrices");
                }
            }

            const f = 1 / math.tan(fov / 2);
            const fnf = far - near;

            return Self{
                .data = .{
                    .{ f / aspect, 0, 0, 0 },
                    .{ 0, f, 0, 0 },
                    .{ 0, 0, (far + near) / fnf, -(2 * far * near) / fnf },
                    .{ 0, 0, 1, 0 },
                },
            };
        }

        pub fn translation(x: T, y: T, z: T) Self {
            comptime {
                if (r != 4 or c != 4) {
                    @compileError("translation is only defined for 4x4 matrices");
                }
            }

            return Self{
                .data = .{
                    .{ 1, 0, 0, x },
                    .{ 0, 1, 0, y },
                    .{ 0, 0, 1, z },
                    .{ 0, 0, 0, 1 },
                },
            };
        }

        pub fn translationVec3(v: vec.Vec(3, T)) Self {
            comptime {
                if (r != 4 or c != 4) {
                    @compileError("translationVec3 is only defined for 4x4 matrices");
                }
            }

            return Self.translation(v.data[0], v.data[1], v.data[2]);
        }

        /// Returns a right-handed rotation transformation matrix.
        /// `angle` takes in radians.
        pub fn rotationRH(axis: vec.Vec(3, T), angle: T) Self {
            comptime {
                if (r != 4 or c != 4) {
                    @compileError("rotation is only defined for 4x4 matrices");
                }
            }

            var result = Self.identity();

            const rads = angle;
            const cos_rads = math.cos(rads);
            const s = math.sin(rads);
            const omc = 1.0 - cos_rads;

            const x = axis.data[0];
            const y = axis.data[1];
            const z = axis.data[2];

            result.data[0][0] = x * x * omc + c;
            result.data[0][1] = x * y * omc - z * s;
            result.data[0][2] = x * z * omc + y * s;

            result.data[1][0] = y * x * omc + z * s;
            result.data[1][1] = y * y * omc + c;
            result.data[1][2] = y * z * omc - x * s;

            result.data[2][0] = z * x * omc - y * s;
            result.data[2][1] = z * y * omc + x * s;
            result.data[2][2] = z * z * omc + c;

            return result;
        }

        /// Returns a right-handed rotation transformation matrix.
        /// `angle` takes in radians.
        pub fn rotationLH(axis: vec.Vec(3, T), angle: T) Self {
            comptime {
                if (r != 4 or c != 4) {
                    @compileError("rotation is only defined for 4x4 matrices");
                }
            }

            var result = Self.identity();

            const rads = angle;
            const cos_rads = math.cos(rads);
            const s = -math.sin(rads);
            const omc = 1.0 - cos_rads;

            const x = axis.data[0];
            const y = axis.data[1];
            const z = axis.data[2];

            result.data[0][0] = x * x * omc + c;
            result.data[0][1] = x * y * omc - z * s;
            result.data[0][2] = x * z * omc + y * s;

            result.data[1][0] = y * x * omc + z * s;
            result.data[1][1] = y * y * omc + c;
            result.data[1][2] = y * z * omc - x * s;

            result.data[2][0] = z * x * omc - y * s;
            result.data[2][1] = z * y * omc + x * s;
            result.data[2][2] = z * z * omc + c;

            return result;
        }

        pub fn scaling(x: T, y: T, z: T) Self {
            comptime {
                if (r != 4 or c != 4) {
                    @compileError("scaling is only defined for 4x4 matrices");
                }
            }

            return Self{
                .data = .{
                    .{ x, 0, 0, 0 },
                    .{ 0, y, 0, 0 },
                    .{ 0, 0, z, 0 },
                    .{ 0, 0, 0, 1 },
                },
            };
        }

        pub fn scalingVec3(v: vec.Vec(3, T)) Self {
            comptime {
                if (r != 4 or c != 4) {
                    @compileError("scalingVec3 is only defined for 4x4 matrices");
                }
            }

            return Self.scaling(v.data[0], v.data[1], v.data[2]);
        }
    };
}

pub const Mat2f = Mat(2, 2, f32);
pub const Mat2 = Mat(2, 2, f64);

pub const Mat3f = Mat(3, 3, f32);
pub const Mat3 = Mat(3, 3, f64);

pub const Mat4f = Mat(4, 4, f32);
pub const Mat4 = Mat(4, 4, f64);
