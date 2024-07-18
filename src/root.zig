const std = @import("std");

const zm = @This();

/// Takes in a floating point type representing degrees.
/// Returns the equivalent in radians.
pub fn toRaidans(degress: anytype) @TypeOf(degress) {
    const T = @TypeOf(degress);
    return switch (T) {
        f32, f64, comptime_float => degress * std.math.rad_per_deg,
        else => @compileError("toRadians not implemented for " ++ @typeName(T)),
    };
}

/// Takes in a floating point type representing radians.
/// Returns the equivalent in degrees.
pub fn toDegrees(radians: anytype) @TypeOf(radians) {
    const T = @TypeOf(radians);
    return switch (T) {
        f32, f64, comptime_float => radians * std.math.deg_per_rad,
        else => @compileError("toDegrees not implemented for " ++ @typeName(T)),
    };
}

/// Clamps the value `n` between `low_bound` and `high_bound`.
/// Must be a floating point type.
pub fn clamp(n: anytype, low_bound: @TypeOf(n), high_bound: @TypeOf(n)) @TypeOf(n) {
    const T = @TypeOf(n);
    return switch (T) {
        f32, f64, comptime_float => @max(low_bound, @min(n, high_bound)),
        else => @compileError("clamp not implemented for " ++ @typeName(T)),
    };
}

/// No extrapolation, clamps `t`.
pub fn lerp(a: anytype, b: @TypeOf(a), t: @TypeOf(a)) @TypeOf(a) {
    const T = @TypeOf(a);
    switch (T) {
        f32, f64, comptime_float => {
            const l = zm.clamp(t, 0.0, 1.0);
            return (1 - l) * a + l * b;
        },
        else => @compileError("clamp not implemented for " ++ @typeName(T)),
    }
}

/// Returns a Vec2 type with T being the component type.
pub fn Vec2Base(comptime T: type) type {
    return struct {
        const Self = @This();

        data: @Vector(2, T),

        /// Creates a Vec2 from the given components.
        pub inline fn from(in_x: T, in_y: T) Self {
            return .{
                .data = .{ in_x, in_y },
            };
        }

        pub inline fn x(self: Self) T {
            return self.data[0];
        }

        pub inline fn y(self: Self) T {
            return self.data[1];
        }

        pub inline fn add(l: Self, r: Self) Self {
            return Self{
                .data = l.data + r.data,
            };
        }

        pub inline fn neg(self: Self) Self {
            return Self{
                .data = -self.data,
            };
        }

        pub inline fn scale(self: *Self, s: T) void {
            self.data *= @splat(s);
        }

        pub fn squareLength(self: Self) T {
            return self.x() * self.x() + self.y() * self.y();
        }

        pub fn length(self: Self) T {
            return @sqrt(self.squareLength());
        }

        pub fn normalize(self: *Self) void {
            self.scale(1 / self.length());
        }

        /// Returns the dot product of the two given vectors.
        pub fn dot(l: Self, r: Self) T {
            return l.x() * r.x() + l.y() * r.y() + l.z() * r.z();
        }

        /// No extrapolation, clamps `t`.
        pub fn lerp(a: Self, b: Self, t: T) Self {
            const l = zm.clamp(t, 0.0, 1.0);
            return Self{
                .data = .{
                    (1 - l) * a.x() + l * b.x(),
                    (1 - l) * a.y() + l * b.y(),
                },
            };
        }
    };
}

// Builtin Vec2Base types
pub const Vec2 = Vec2Base(f32);
pub const Vec2d = Vec2Base(f64);
pub const Vec2i = Vec2Base(i32);

/// Returns a Vec3 type with T being the component type.
pub fn Vec3Base(comptime T: type) type {
    return struct {
        const Self = @This();

        data: @Vector(3, T),

        /// Creates a Vec3 from the given components.
        pub inline fn from(in_x: T, in_y: T, in_z: T) Self {
            return .{
                .data = .{ in_x, in_y, in_z },
            };
        }

        pub inline fn x(self: Self) T {
            return self.data[0];
        }

        pub inline fn y(self: Self) T {
            return self.data[1];
        }

        pub inline fn z(self: Self) T {
            return self.data[2];
        }

        /// Returns a 2D-vector with the `x` and `y` components.
        pub fn xy(self: Self) Vec2Base(T) {
            return Vec2Base(T).from(self.x(), self.y());
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

        pub fn scale(self: *Self, s: T) void {
            self.data *= @splat(s);
        }

        pub fn squareLength(self: Self) T {
            return self.x() * self.x() + self.y() * self.y() + self.z() * self.z();
        }

        pub fn length(self: Self) T {
            return @sqrt(self.squareLength());
        }

        pub fn normalize(self: *Self) void {
            self.scale(1 / self.length());
        }

        /// Returns the dot product of the given vectors.
        pub fn dot(l: Self, r: Self) T {
            return l.x() * r.x() + l.y() * r.y() + l.z() * r.z();
        }

        /// No extrapolation, clamps `t`.
        pub fn lerp(a: Self, b: Self, t: T) Self {
            const l = zm.clamp(t, 0.0, 1.0);
            return Self{
                .data = .{
                    (1 - l) * a.x() + l * b.x(),
                    (1 - l) * a.y() + l * b.y(),
                    (1 - l) * a.z() + l * b.z(),
                },
            };
        }

        /// Returns the cross product of the given vectors.
        pub fn cross(l: Self, r: Self) Self {
            return .{
                l.y() * r.z() - l.z() * r.y(),
                l.z() * r.x() - l.x() * r.z(),
                l.x() * r.y() - l.y() * r.x(),
            };
        }
    };
}

// Default Vec3Base types
pub const Vec3 = Vec3Base(f32);
pub const Vec3d = Vec3Base(f64);
pub const Vec3i = Vec3Base(i32);

/// Returns a Vec4 type with T being the component type.
pub fn Vec4Base(comptime T: type) type {
    return struct {
        const Self = @This();

        data: @Vector(4, T),

        /// Creates a Vec4 from the given components.
        pub inline fn from(in_x: T, in_y: T, in_z: T, in_w: T) Self {
            return .{
                .data = .{ in_x, in_y, in_z, in_w },
            };
        }

        pub inline fn x(self: Self) T {
            return self.data[0];
        }

        pub inline fn y(self: Self) T {
            return self.data[1];
        }

        pub inline fn z(self: Self) T {
            return self.data[2];
        }

        pub inline fn w(self: Self) T {
            return self.data[3];
        }

        /// Returns a 2D-vector with the `x` and `y` components.
        pub fn xy(self: Self) Vec2Base(T) {
            return Vec2Base(T).from(self.x(), self.y());
        }

        /// Returns a 3D-vector with the `x`, `y` and `z` components.
        pub fn xyz(self: Self) Vec3Base(T) {
            return Vec3Base(T).from(self.x(), self.y(), self.z());
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

        pub fn scale(self: *Self, s: T) void {
            self.data *= @splat(s);
        }

        pub fn squareLength(self: Self) T {
            return self.x() * self.x() + self.y() * self.y() + self.z() * self.z() + self.w() * self.w();
        }

        pub fn length(self: Self) T {
            return zm.sqrt(self.squareLength());
        }

        pub fn normalize(self: *Self) void {
            self.scale(1 / self.length());
        }

        /// Returns the dot product of the given vectors.
        pub fn dot(l: Self, r: Self) T {
            return l.x() * r.x() + l.y() * r.y() + l.z() * r.z() + l.w() * r.w();
        }

        /// No extrapolation, clamps `t`.
        pub fn lerp(a: Self, b: Self, t: T) Self {
            const l = zm.clamp(t, 0.0, 1.0);
            return Self{
                .data = .{
                    (1 - l) * a.x() + l * b.x(),
                    (1 - l) * a.y() + l * b.y(),
                    (1 - l) * a.z() + l * b.z(),
                    (1 - l) * a.w() + l * b.w(),
                },
            };
        }
    };
}

// Default Vec4Base types
pub const Vec4 = Vec4Base(f32);
pub const Vec4d = Vec4Base(f64);
pub const Vec4i = Vec4Base(i32);

/// Returns a Mat4 type with T being the component type.
pub fn Mat4Base(comptime T: type) type {
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
            return Self.diagonal(1.0);
        }

        pub fn orthographic(left: T, right: T, top: T, bottom: T, near: T, far: T) Self {
            return Self{
                .data = .{
                    2 / (right - left), 0,                  0,                 -(right + left) / (right - left),
                    0,                  2 / (top - bottom), 0,                 -(top + bottom) / (top - bottom),
                    0,                  0,                  -2 / (far - near), -(far + near) / (far - near),
                    0,                  0,                  0,                 1.0,
                },
            };
        }

        /// `fov` takes in degrees
        pub fn perspective(fov: T, aspect: T, near: T, far: T) Self {
            const fov_rad = toRaidans(fov);
            return Self{
                .data = .{
                    1 / (aspect * @tan(fov_rad / 2)), 0,                     0,                            0,
                    0,                                1 / @tan(fov_rad / 2), 0,                            0,
                    0,                                0,                     -(far + near) / (far - near), -(2 * far * near) / (far - near),
                    0,                                0,                     -1,                           0,
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

        /// `angle` takes in degrees
        pub fn rotation(axis: Vec3, angle: T) Self {
            var result = Self.identity();

            const r = toRaidans(angle);
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

        pub fn scale(self: *Self, s: T) void {
            self.data *= @splat(s);
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

// Default Mat4Base types
pub const Mat4 = Mat4Base(f32);
pub const Mat4d = Mat4Base(f64);
pub const Mat4i = Mat4Base(i32);
