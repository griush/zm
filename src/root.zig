//! zm - SIMD Math library fully cross-platform

const std = @import("std");

const zm = @This();

/// Takes in a floating point type representing degrees.
/// Returns the equivalent in radians.
pub fn toRadians(degress: anytype) @TypeOf(degress) {
    const T = @TypeOf(degress);
    const type_info = @typeInfo(T);
    return switch (type_info) {
        .Float, .ComptimeFloat => degress * std.math.rad_per_deg,
        else => @compileError("toRadians not implemented for " ++ @typeName(T)),
    };
}

/// Takes in a floating point type representing radians.
/// Returns the equivalent in degrees.
pub fn toDegrees(radians: anytype) @TypeOf(radians) {
    const T = @TypeOf(radians);
    const type_info = @typeInfo(T);
    return switch (type_info) {
        .Float, .ComptimeFloat => radians * std.math.deg_per_rad,
        else => @compileError("toDegrees not implemented for " ++ @typeName(T)),
    };
}

/// Clamps the value `n` between `low_bound` and `high_bound`.
/// Must be a floating point type.
pub fn clamp(n: anytype, low_bound: @TypeOf(n), high_bound: @TypeOf(n)) @TypeOf(n) {
    const T = @TypeOf(n);
    const type_info = @typeInfo(T);
    return switch (type_info) {
        .Int, .Float, .ComptimeInt, .ComptimeFloat => @max(low_bound, @min(n, high_bound)),
        else => @compileError("clamp not implemented for " ++ @typeName(T)),
    };
}

/// No extrapolation, clamps `t`.
pub fn lerp(a: anytype, b: @TypeOf(a), t: @TypeOf(a)) @TypeOf(a) {
    const T = @TypeOf(a);
    const type_info = @typeInfo(T);
    return switch (type_info) {
        .Float, .ComptimeFloat => {
            const l = zm.clamp(t, 0.0, 1.0);
            return (1 - l) * a + l * b;
        },
        else => @compileError("lerp not implemented for " ++ @typeName(T)),
    };
}

// Vectors
const Vec = @import("vector.zig").Vec;

// Builtin Vec2Base types
pub const Vec2 = Vec(2, f32);
pub const Vec2d = Vec(2, f64);
pub const Vec2i = Vec(2, i32);

// Builtin Vec3Base types
pub const Vec3 = Vec(3, f32);
pub const Vec3d = Vec(3, f64);
pub const Vec3i = Vec(3, i32);

// Builtin Vec4Base types
pub const Vec4 = Vec(4, f32);
pub const Vec4d = Vec(4, f64);
pub const Vec4i = Vec(4, i32);

/// Returns a Mat2 type with T being the element type.
pub fn Mat2Base(comptime T: type) type {
    const type_info = @typeInfo(T);
    switch (type_info) {
        .Int, .Float => {},
        else => @compileError("Mat2Base only supports numerical type. Type '" ++ @typeName(T) ++ "' is not supported"),
    }

    return struct {
        const Self = @This();

        data: @Vector(4, T),

        /// Creates a diagonal matrix with the given value.
        pub inline fn diagonal(r: T) Self {
            return Self{
                .data = .{
                    r, 0,
                    0, r,
                },
            };
        }

        /// Returns the identity matrix.
        pub fn identity() Self {
            return Self.diagonal(1);
        }

        // Transformations

        /// `angle` takes in radians
        pub fn rotation(angle: T) Self {
            const a = angle;

            return Self{
                .data = .{
                    @cos(a), -@sin(a),
                    @sin(a), @cos(a),
                },
            };
        }

        pub fn scaling(sx: T, sy: T) Self {
            return Self{
                .data = .{
                    sx, 0,
                    0,  sy,
                },
            };
        }

        pub fn scalingVec2(s: Vec(2, T)) Self {
            return Self{
                .data = .{
                    s.x(), 0,
                    0,     s.y(),
                },
            };
        }

        pub fn add(l: Self, r: Self) Self {
            return Self{
                .data = l.data + r.data,
            };
        }

        pub fn neg(self: Self) Self {
            return Self{
                .data = -self.data,
            };
        }

        pub fn scaleMut(self: *Self, s: T) Self {
            self.data *= @splat(s);
            return self.*;
        }

        pub fn multiply(l: Self, r: Self) Self {
            var data: @Vector(4, T) = @splat(0.0);

            var row: usize = 0;
            while (row < 2) : (row += 1) {
                var col: usize = 0;
                while (col < 2) : (col += 1) {
                    var e: usize = 0;
                    while (e < 2) : (e += 1) {
                        data[col + row * 2] += l.data[e + row * 2] * r.data[e * 2 + col];
                    }
                }
            }

            return Self{
                .data = data,
            };
        }

        pub fn multiplyVec2(self: Self, vec: Vec(2, T)) Vec(2, T) {
            return Vec(2, T){
                .data = .{
                    self.data[0] * vec.x() + self.data[1] * vec.y(),
                    self.data[2] * vec.x() + self.data[3] * vec.y(),
                },
            };
        }

        pub fn determinant(self: Self) Self {
            const a = self.data[0];
            const b = self.data[1];
            const c = self.data[2];
            const d = self.data[3];

            return (a * d - b * c);
        }

        pub fn transpose(self: Self) Self {
            var result = Self.identity();

            var row: usize = 0;
            while (row < 2) : (row += 1) {
                var col: usize = 0;
                while (col < 2) : (col += 1) {
                    result.data[col * 2 + row] = self.data[row * 2 + col];
                }
            }

            return result;
        }

        pub fn inverse(self: Self) Self {
            const a = self.data[0];
            const b = self.data[1];
            const c = self.data[2];
            const d = self.data[3];

            const det = 1.0 / (a * d - b * c);

            return Self{
                .data = .{
                    d / det,  -b / det,
                    -c / det, a / det,
                },
            };
        }
    };
}

/// Returns a Mat2 type with T being the element type.
pub fn Mat3Base(comptime T: type) type {
    const type_info = @typeInfo(T);
    switch (type_info) {
        .Int, .Float => {},
        else => @compileError("Mat3Base only supports numerical type. Type '" ++ @typeName(T) ++ "' is not supported"),
    }

    return struct {
        const Self = @This();

        data: @Vector(9, T),

        /// Creates a diagonal matrix with the given value.
        pub inline fn diagonal(r: T) Self {
            return Self{
                .data = .{
                    r, 0, 0,
                    0, r, 0,
                    0, 0, r,
                },
            };
        }

        /// Returns the identity matrix.
        pub fn identity() Self {
            return Self.diagonal(1);
        }

        pub fn translation(tx: T, ty: T) Self {
            return Self{
                1, 0, tx,
                0, 1, ty,
                0, 0, 1,
            };
        }

        pub fn translationVec2(v: Vec(2, T)) Self {
            return Self{
                1, 0, v.x(),
                0, 1, v.y(),
                0, 0, 1,
            };
        }

        /// `angle` takes in radians
        pub fn rotation(angle: T) Self {
            const a = angle;

            return Self{
                .data = .{
                    @cos(a), -@sin(a), 0,
                    @sin(a), @cos(a),  0,
                    0,       0,        1,
                },
            };
        }

        pub fn scaling(sx: T, sy: T) Self {
            return Self{
                .data = .{
                    sx, 0,  0,
                    0,  sy, 0,
                    0,  0,  1,
                },
            };
        }

        pub fn scalingVec2(v: Vec(2, T)) Self {
            return Self{
                .data = .{
                    v.x(), 0,     0,
                    0,     v.y(), 0,
                    0,     0,     1,
                },
            };
        }

        pub inline fn add(l: Self, r: Self) Self {
            return Self{
                .data = l.data + r.data,
            };
        }

        pub fn neg(self: Self) Self {
            return Self{
                .data = -self.data,
            };
        }

        pub fn scaleMut(self: *Self, s: T) Self {
            self.data *= @splat(s);
            return self.*;
        }

        pub fn multiplyVec3(self: Self, vec: Vec(3, T)) Vec(3, T) {
            return Vec(3, T){
                .data = .{
                    self.data[0] * vec.x() + self.data[1] * vec.y() + self.data[2] * vec.z(),
                    self.data[3] * vec.x() + self.data[4] * vec.y() + self.data[5] * vec.z(),
                    self.data[6] * vec.x() + self.data[7] * vec.y() + self.data[8] * vec.z(),
                },
            };
        }

        /// Multiplies two matrices together
        pub fn multiply(l: Self, r: Self) Self {
            var data: @Vector(9, T) = @splat(0.0);

            var row: usize = 0;
            while (row < 3) : (row += 1) {
                var col: usize = 0;
                while (col < 3) : (col += 1) {
                    var e: usize = 0;
                    while (e < 3) : (e += 1) {
                        data[col + row * 3] += l.data[e + row * 3] * r.data[e * 3 + col];
                    }
                }
            }

            return Self{
                .data = data,
            };
        }

        /// Transposes the matrix.
        pub fn transpose(self: Self) Self {
            var result = Self.identity();

            var row: usize = 0;
            while (row < 3) : (row += 1) {
                var col: usize = 0;
                while (col < 3) : (col += 1) {
                    result.data[col * 3 + row] = self.data[row * 3 + col];
                }
            }

            return result;
        }
    };
}

/// Returns a Mat4 type with T being the element type.
pub fn Mat4Base(comptime T: type) type {
    const type_info = @typeInfo(T);
    switch (type_info) {
        .Int, .Float => {},
        else => @compileError("Mat4Base only supports numerical type. Type '" ++ @typeName(T) ++ "' is not supported"),
    }

    return struct {
        const Self = @This();

        data: @Vector(16, T),

        /// Creates a diagonal matrix with the given value.
        pub inline fn diagonal(r: T) Self {
            return Self{
                .data = .{
                    r, 0, 0, 0,
                    0, r, 0, 0,
                    0, 0, r, 0,
                    0, 0, 0, r,
                },
            };
        }

        /// Returns the identity matrix.
        pub fn identity() Self {
            return Self.diagonal(1);
        }

        pub fn orthographic(left: T, right: T, bottom: T, top: T, near: T, far: T) Self {
            return Self{
                .data = .{
                    2 / (right - left), 0,                  0,                 -(right + left) / (right - left),
                    0,                  2 / (top - bottom), 0,                 -(top + bottom) / (top - bottom),
                    0,                  0,                  -2 / (far - near), -(far + near) / (far - near),
                    0,                  0,                  0,                 1.0,
                },
            };
        }

        /// `fov` takes in radians
        pub fn perspective(fov: T, aspect: T, near: T, far: T) Self {
            return Self{
                .data = .{
                    1 / (aspect * @tan(fov / 2)), 0,                 0,                            0,
                    0,                            1 / @tan(fov / 2), 0,                            0,
                    0,                            0,                 -(far + near) / (far - near), -(2 * far * near) / (far - near),
                    0,                            0,                 -1,                           0,
                },
            };
        }

        pub fn translation(x: T, y: T, z: T) Self {
            return Self{
                .data = .{
                    1, 0, 0, x,
                    0, 1, 0, y,
                    0, 0, 1, z,
                    0, 0, 0, 1,
                },
            };
        }

        pub fn translationVec3(vec: Vec(3, T)) Self {
            return Self.translation(vec.x(), vec.y(), vec.z());
        }

        /// Returns a rotation transformation matrix
        /// `angle` takes in radians
        pub fn rotation(axis: Vec3, angle: T) Self {
            var result = Self.identity();

            const r = angle;
            const c = @cos(r);
            const s = @sin(r);
            const omc = 1.0 - c;

            const x = axis.x();
            const y = axis.y();
            const z = axis.z();

            result.data[0 + 0 * 4] = x * x * omc + c;
            result.data[0 + 1 * 4] = y * x * omc + z * s;
            result.data[0 + 2 * 4] = x * z * omc - y * s;

            result.data[1 + 0 * 4] = x * y * omc - z * s;
            result.data[1 + 1 * 4] = y * y * omc + c;
            result.data[1 + 2 * 4] = y * z * omc + x * s;

            result.data[2 + 0 * 4] = x * z * omc + y * s;
            result.data[2 + 1 * 4] = y * z * omc - x * s;
            result.data[2 + 2 * 4] = z * z * omc + c;

            return result;
        }

        pub fn scaling(x: T, y: T, z: T) Self {
            return Self{
                .data = .{
                    x, 0, 0, 0,
                    0, y, 0, 0,
                    0, 0, z, 0,
                    0, 0, 0, 1,
                },
            };
        }

        /// Returns a `Mat4Base(T)` from a `QuaternionBase(T)`
        pub fn fromQuaternion(q: QuaternionBase(T)) Self {
            // From https://www.euclideanspace.com/maths/geometry/rotations/conversions/quaternionToMatrix/index.htm
            var result = Self.identity();

            // Row 1
            result.data[0] = 1 - 2 * q.y * q.y - 2 * q.z * q.z;
            result.data[1] = 2 * q.x * q.y - 2 * q.z * q.w;
            result.data[2] = 2 * q.x * q.z + 2 * q.y * q.w;
            // Row 2
            result.data[4] = 2 * q.x * q.y + 2 * q.z * q.w;
            result.data[5] = 1 - 2 * q.x * q.x - 2 * q.z * q.z;
            result.data[6] = 2 * q.y * q.z - 2 * q.x * q.w;
            // Row 3
            result.data[8] = 2 * q.x * q.z - 2 * q.y * q.w;
            result.data[9] = 2 * q.y * q.z + 2 * q.x * q.w;
            result.data[10] = 1 - 2 * q.x * q.x - 2 * q.y * q.y;

            return result;
        }

        pub fn add(l: Self, r: Self) Self {
            return Self{
                .data = l.data + r.data,
            };
        }

        pub fn neg(self: Self) Self {
            return Self{
                .data = -self.data,
            };
        }

        pub fn scaleMut(self: *Self, s: T) Self {
            self.data *= @splat(s);
            return self.*;
        }

        pub fn multiply(l: Self, r: Self) Self {
            var data: @Vector(16, T) = @splat(0.0);

            var row: usize = 0;
            while (row < 4) : (row += 1) {
                var col: usize = 0;
                while (col < 4) : (col += 1) {
                    var e: usize = 0;
                    while (e < 4) : (e += 1) {
                        data[col + row * 4] += l.data[e + row * 4] * r.data[e * 4 + col];
                    }
                }
            }

            return Self{
                .data = data,
            };
        }

        pub fn multiplyByVec4(m: Self, v: Vec(4, T)) Vec(4, T) {
            return Vec(4, T){
                .data = .{
                    m.data[0] * v.x() + m.data[1] * v.y() + m.data[2] * v.z() + m.data[3] * v.w(),
                    m.data[4] * v.x() + m.data[5] * v.y() + m.data[6] * v.z() + m.data[7] * v.w(),
                    m.data[8] * v.x() + m.data[9] * v.y() + m.data[10] * v.z() + m.data[11] * v.w(),
                    m.data[12] * v.x() + m.data[13] * v.y() + m.data[14] * v.z() + m.data[15] * v.w(),
                },
            };
        }

        /// This is useful as you need to transpose matrices for OpenGL
        pub fn transpose(self: Self) Self {
            var result = Self.identity();

            var row: usize = 0;
            while (row < 4) : (row += 1) {
                var col: usize = 0;
                while (col < 4) : (col += 1) {
                    result.data[col * 4 + row] = self.data[row * 4 + col];
                }
            }

            return result;
        }

        pub fn inverse(self: Self) Self {
            const m = self.data;

            const t0 = m[10] * m[15];
            const t1 = m[14] * m[11];
            const t2 = m[6] * m[15];
            const t3 = m[14] * m[7];
            const t4 = m[6] * m[11];
            const t5 = m[10] * m[7];
            const t6 = m[2] * m[15];
            const t7 = m[14] * m[3];
            const t8 = m[2] * m[11];
            const t9 = m[10] * m[3];
            const t10 = m[2] * m[7];
            const t11 = m[6] * m[3];
            const t12 = m[8] * m[13];
            const t13 = m[12] * m[9];
            const t14 = m[4] * m[13];
            const t15 = m[12] * m[5];
            const t16 = m[4] * m[9];
            const t17 = m[8] * m[5];
            const t18 = m[0] * m[13];
            const t19 = m[12] * m[1];
            const t20 = m[0] * m[9];
            const t21 = m[8] * m[1];
            const t22 = m[0] * m[5];
            const t23 = m[4] * m[1];

            var result = Self.diagonal(0.0);

            result.data[0] = (t0 * m[5] + t3 * m[9] + t4 * m[13]) - (t1 * m[5] + t2 * m[9] + t5 * m[13]);
            result.data[1] = (t1 * m[1] + t6 * m[9] + t9 * m[13]) - (t0 * m[1] + t7 * m[9] + t8 * m[13]);
            result.data[2] = (t2 * m[1] + t7 * m[5] + t10 * m[13]) - (t3 * m[1] + t6 * m[5] + t11 * m[13]);
            result.data[3] = (t5 * m[1] + t8 * m[5] + t11 * m[9]) - (t4 * m[1] + t9 * m[5] + t10 * m[9]);

            const d = 1.0 / (m[0] * result.data[0] + m[4] * result.data[1] + m[8] * result.data[2] + m[12] * result.data[3]);

            result.data[0] = d * result.data[0];
            result.data[1] = d * result.data[1];
            result.data[2] = d * result.data[2];
            result.data[3] = d * result.data[3];
            result.data[4] = d * ((t1 * m[4] + t2 * m[8] + t5 * m[12]) - (t0 * m[4] + t3 * m[8] + t4 * m[12]));
            result.data[5] = d * ((t0 * m[0] + t7 * m[8] + t8 * m[12]) - (t1 * m[0] + t6 * m[8] + t9 * m[12]));
            result.data[6] = d * ((t3 * m[0] + t6 * m[4] + t11 * m[12]) - (t2 * m[0] + t7 * m[4] + t10 * m[12]));
            result.data[7] = d * ((t4 * m[0] + t9 * m[4] + t10 * m[8]) - (t5 * m[0] + t8 * m[4] + t11 * m[8]));
            result.data[8] = d * ((t12 * m[7] + t15 * m[11] + t16 * m[15]) - (t13 * m[7] + t14 * m[11] + t17 * m[15]));
            result.data[9] = d * ((t13 * m[3] + t18 * m[11] + t21 * m[15]) - (t12 * m[3] + t19 * m[11] + t20 * m[15]));
            result.data[10] = d * ((t14 * m[3] + t19 * m[7] + t22 * m[15]) - (t15 * m[3] + t18 * m[7] + t23 * m[15]));
            result.data[11] = d * ((t17 * m[3] + t20 * m[7] + t23 * m[11]) - (t16 * m[3] + t21 * m[7] + t22 * m[11]));
            result.data[12] = d * ((t14 * m[10] + t17 * m[14] + t13 * m[6]) - (t16 * m[14] + t12 * m[6] + t15 * m[10]));
            result.data[13] = d * ((t20 * m[14] + t12 * m[2] + t19 * m[10]) - (t18 * m[10] + t21 * m[14] + t13 * m[2]));
            result.data[14] = d * ((t18 * m[6] + t23 * m[14] + t15 * m[2]) - (t22 * m[14] + t14 * m[2] + t19 * m[6]));
            result.data[15] = d * ((t22 * m[10] + t16 * m[2] + t21 * m[6]) - (t20 * m[6] + t23 * m[10] + t17 * m[2]));

            return result;
        }
    };
}

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
            const x = Self.fromAxis(v.x(), Vec3.right());
            const y = Self.fromAxis(v.y(), Vec3.up());
            const z = Self.fromAxis(v.z(), Vec3.forward());

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
            const w = zm.lerp(self.w, other.w, t);
            const x = zm.lerp(self.x, other.x, t);
            const y = zm.lerp(self.y, other.y, t);
            const z = zm.lerp(self.z, other.z, t);

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

            const theta = std.math.acos(zm.clamp(cos_theta, -1, 1));
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

// Builtin Mat2Base types
pub const Mat2 = Mat2Base(f32);
pub const Mat2d = Mat2Base(f64);
pub const Mat2i = Mat2Base(i32);

// Builtin Mat3Base types
pub const Mat3 = Mat3Base(f32);
pub const Mat3d = Mat3Base(f64);
pub const Mat3i = Mat3Base(i32);

// Builtin Mat4Base types
pub const Mat4 = Mat4Base(f32);
pub const Mat4d = Mat4Base(f64);
pub const Mat4i = Mat4Base(i32);

// Builtin Quaternion types
pub const Quaternion = QuaternionBase(f32);
pub const Quaterniond = QuaternionBase(f64);
