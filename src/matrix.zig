const Vec = @import("vector.zig").Vec;
const QuaternionBase = @import("quaternion.zig").QuaternionBase;

/// Returns a Mat2 type with `Element` being the element type.
/// Matrices are row-major.
pub fn Mat2Base(comptime Element: type) type {
    const type_info = @typeInfo(Element);
    switch (type_info) {
        .Float => {},
        else => @compileError("Mat2Base only supports numerical type. Type '" ++ @typeName(Element) ++ "' is not supported"),
    }

    return struct {
        const Self = @This();

        const DataType = @Vector(4, Element);

        data: DataType,

        /// Creates a diagonal matrix with the given value.
        pub inline fn diagonal(value: Element) Self {
            return Self{
                .data = .{
                    value, 0,
                    0,     value,
                },
            };
        }

        /// Returns the identity matrix.
        pub fn identity() Self {
            return Self.diagonal(1);
        }

        // Transformations

        /// `angle` takes in radians
        pub fn rotation(angle: Element) Self {
            const a = angle;

            return Self{
                .data = .{
                    @cos(a), -@sin(a),
                    @sin(a), @cos(a),
                },
            };
        }

        pub fn scaling(sx: Element, sy: Element) Self {
            return Self{
                .data = .{
                    sx, 0,
                    0,  sy,
                },
            };
        }

        pub fn scalingVec2(s: Vec(2, Element)) Self {
            return Self{
                .data = .{
                    s.x(), 0,
                    0,     s.y(),
                },
            };
        }

        pub fn add(lhs: Self, rhs: Self) Self {
            return Self{
                .data = lhs.data + rhs.data,
            };
        }

        pub fn neg(self: Self) Self {
            return Self{
                .data = -self.data,
            };
        }

        pub fn scale(self: Self, scalar: Element) Self {
            return Self{
                .data = self.data * @as(DataType, @splat(scalar)),
            };
        }

        pub fn multiply(lhs: Self, rhs: Self) Self {
            var data: DataType = @splat(0.0);

            var row: usize = 0;
            while (row < 2) : (row += 1) {
                var col: usize = 0;
                while (col < 2) : (col += 1) {
                    var e: usize = 0;
                    while (e < 2) : (e += 1) {
                        data[col + row * 2] += lhs.data[e + row * 2] * rhs.data[e * 2 + col];
                    }
                }
            }

            return Self{
                .data = data,
            };
        }

        pub fn multiplyVec2(self: Self, vec: Vec(2, Element)) Vec(2, Element) {
            return Vec(2, Element){
                .data = .{
                    self.data[0] * vec.x() + self.data[1] * vec.y(),
                    self.data[2] * vec.x() + self.data[3] * vec.y(),
                },
            };
        }

        pub fn determinant(self: Self) Element {
            const a = self.data[0];
            const b = self.data[1];
            const c = self.data[2];
            const d = self.data[3];

            return (a * d - b * c);
        }

        pub fn transpose(self: Self) Self {
            var result = Self.identity();

            for (0..2) |row| {
                for (0..2) |col| {
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

/// Returns a Mat2 type with `Element` being the element type.
/// Matrices are row-major.
pub fn Mat3Base(comptime Element: type) type {
    const type_info = @typeInfo(Element);
    switch (type_info) {
        .Float => {},
        else => @compileError("Mat3Base only supports numerical type. Type '" ++ @typeName(Element) ++ "' is not supported"),
    }

    return struct {
        const Self = @This();

        const DataType = @Vector(9, Element);

        data: DataType,

        /// Creates a diagonal matrix with the given value.
        pub inline fn diagonal(value: Element) Self {
            return Self{
                .data = .{
                    value, 0,     0,
                    0,     value, 0,
                    0,     0,     value,
                },
            };
        }

        /// Returns the identity matrix.
        pub fn identity() Self {
            return Self.diagonal(1);
        }

        pub fn translation(tx: Element, ty: Element) Self {
            return Self{
                .data = .{
                    1, 0, tx,
                    0, 1, ty,
                    0, 0, 1,
                },
            };
        }

        pub fn translationVec2(v: Vec(2, Element)) Self {
            return Self{
                .data = .{
                    1, 0, v.x(),
                    0, 1, v.y(),
                    0, 0, 1,
                },
            };
        }

        /// `angle` takes in radians
        pub fn rotation(angle: Element) Self {
            const a = angle;

            return Self{
                .data = .{
                    @cos(a), -@sin(a), 0,
                    @sin(a), @cos(a),  0,
                    0,       0,        1,
                },
            };
        }

        pub fn scaling(sx: Element, sy: Element) Self {
            return Self{
                .data = .{
                    sx, 0,  0,
                    0,  sy, 0,
                    0,  0,  1,
                },
            };
        }

        pub fn scalingVec2(v: Vec(2, Element)) Self {
            return Self{
                .data = .{
                    v.x(), 0,     0,
                    0,     v.y(), 0,
                    0,     0,     1,
                },
            };
        }

        pub inline fn add(lhs: Self, rhs: Self) Self {
            return Self{
                .data = lhs.data + rhs.data,
            };
        }

        pub fn neg(self: Self) Self {
            return Self{
                .data = -self.data,
            };
        }

        pub fn scale(self: Self, scalar: Element) Self {
            return Self{
                .data = self.data * @as(DataType, @splat(scalar)),
            };
        }

        pub fn multiplyVec3(self: Self, vec: Vec(3, Element)) Vec(3, Element) {
            return Vec(3, Element){
                .data = .{
                    self.data[0] * vec.x() + self.data[1] * vec.y() + self.data[2] * vec.z(),
                    self.data[3] * vec.x() + self.data[4] * vec.y() + self.data[5] * vec.z(),
                    self.data[6] * vec.x() + self.data[7] * vec.y() + self.data[8] * vec.z(),
                },
            };
        }

        /// Multiplies two matrices together
        pub fn multiply(lhs: Self, rhs: Self) Self {
            var data: DataType = @splat(0.0);

            var row: usize = 0;
            while (row < 3) : (row += 1) {
                var col: usize = 0;
                while (col < 3) : (col += 1) {
                    var e: usize = 0;
                    while (e < 3) : (e += 1) {
                        data[col + row * 3] += lhs.data[e + row * 3] * rhs.data[e * 3 + col];
                    }
                }
            }

            return Self{
                .data = data,
            };
        }

        pub fn transpose(self: Self) Self {
            var result = Self.identity();

            for (0..3) |row| {
                for (0..3) |col| {
                    result.data[col * 3 + row] = self.data[row * 3 + col];
                }
            }

            return result;
        }
    };
}

/// Returns a Mat4 type with `Element` being the element type.
/// Matrices are row-major.
pub fn Mat4Base(comptime Element: type) type {
    const type_info = @typeInfo(Element);
    switch (type_info) {
        .Float => {},
        else => @compileError("Mat4Base only supports numerical type. Type '" ++ @typeName(Element) ++ "' is not supported"),
    }

    return struct {
        const Self = @This();

        const DataType = @Vector(16, Element);

        data: DataType,

        /// Creates a diagonal matrix with the given value.
        pub inline fn diagonal(value: Element) Self {
            return Self{
                .data = .{
                    value, 0,     0,     0,
                    0,     value, 0,     0,
                    0,     0,     value, 0,
                    0,     0,     0,     value,
                },
            };
        }

        /// Returns the identity matrix.
        pub fn identity() Self {
            return Self.diagonal(1);
        }

        pub fn orthographic(left: Element, right: Element, bottom: Element, top: Element, near: Element, far: Element) Self {
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
        pub fn perspective(fov: Element, aspect: Element, near: Element, far: Element) Self {
            return Self{
                .data = .{
                    1 / (aspect * @tan(fov / 2)), 0,                 0,                            0,
                    0,                            1 / @tan(fov / 2), 0,                            0,
                    0,                            0,                 -(far + near) / (far - near), -(2 * far * near) / (far - near),
                    0,                            0,                 -1,                           0,
                },
            };
        }

        pub fn translation(x: Element, y: Element, z: Element) Self {
            return Self{
                .data = .{
                    1, 0, 0, x,
                    0, 1, 0, y,
                    0, 0, 1, z,
                    0, 0, 0, 1,
                },
            };
        }

        pub fn translationVec3(vec: Vec(3, Element)) Self {
            return Self.translation(vec.x(), vec.y(), vec.z());
        }

        /// Returns a rotation transformation matrix
        /// `angle` takes in radians
        pub fn rotation(axis: Vec(3, Element), angle: Element) Self {
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

        pub fn scaling(x: Element, y: Element, z: Element) Self {
            return Self{
                .data = .{
                    x, 0, 0, 0,
                    0, y, 0, 0,
                    0, 0, z, 0,
                    0, 0, 0, 1,
                },
            };
        }

        pub fn lookAt(eye: Vec(3, Element), target: Vec(3, Element), up: Vec(3, Element)) Self {
            const f = Vec(3, Element).sub(target, eye).normalized();
            const s = f.cross(up).normalized();
            const u = s.cross(f);

            return Self{
                .data = .{
                    s.x(),  s.y(),  s.z(),  -s.dot(eye),
                    u.x(),  u.y(),  u.z(),  -u.dot(eye),
                    -f.x(), -f.y(), -f.z(), f.dot(eye),
                    0,      0,      0,      1,
                },
            };
        }

        /// Returns a `Mat4Base(T)` from a `QuaternionBase(T)`
        pub fn fromQuaternion(q: QuaternionBase(Element)) Self {
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

        pub fn add(lhs: Self, rhs: Self) Self {
            return Self{
                .data = lhs.data + rhs.data,
            };
        }

        pub fn neg(self: Self) Self {
            return Self{
                .data = -self.data,
            };
        }

        pub fn scale(self: Self, scalar: Element) Self {
            return Self{
                .data = self.data * @as(DataType, @splat(scalar)),
            };
        }

        pub fn multiply(lhs: Self, rhs: Self) Self {
            var data: DataType = @splat(0.0);

            var row: usize = 0;
            while (row < 4) : (row += 1) {
                var col: usize = 0;
                while (col < 4) : (col += 1) {
                    var e: usize = 0;
                    while (e < 4) : (e += 1) {
                        data[col + row * 4] += lhs.data[e + row * 4] * rhs.data[e * 4 + col];
                    }
                }
            }

            return Self{
                .data = data,
            };
        }

        pub fn multiplyVec4(m: Self, v: Vec(4, Element)) Vec(4, Element) {
            return Vec(4, Element){
                .data = .{
                    m.data[0] * v.x() + m.data[1] * v.y() + m.data[2] * v.z() + m.data[3] * v.w(),
                    m.data[4] * v.x() + m.data[5] * v.y() + m.data[6] * v.z() + m.data[7] * v.w(),
                    m.data[8] * v.x() + m.data[9] * v.y() + m.data[10] * v.z() + m.data[11] * v.w(),
                    m.data[12] * v.x() + m.data[13] * v.y() + m.data[14] * v.z() + m.data[15] * v.w(),
                },
            };
        }

        /// As `zm` is row-major, matrices should be transposed before passing into OpenGL (which is column-major)
        pub fn transpose(self: Self) Self {
            var result = Self.identity();

            for (0..4) |row| {
                for (0..4) |col| {
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
