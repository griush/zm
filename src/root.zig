const std = @import("std");

const amth = @This();
const RealType = f32;

pub fn toRaidans(deg: RealType) RealType {
    return deg * std.math.rad_per_deg;
}

pub fn toDegrees(rad: RealType) RealType {
    return rad * std.math.deg_per_rad;
}

pub fn abs(x: RealType) RealType {
    return @abs(x);
}

pub fn max(a: RealType, b: RealType) RealType {
    return @max(a, b);
}

pub fn min(a: RealType, b: RealType) RealType {
    return @min(a, b);
}

pub fn clamp(n: RealType, lb: RealType, hb: RealType) RealType {
    return @max(lb, @min(n, hb));
}

/// No extrapolation, clamps t
pub fn lerp(a: RealType, b: RealType, t: RealType) RealType {
    const l = amth.clamp(t, 0.0, 1.0);
    return (1 - l) * a + l * b;
}

pub fn sqrt(x: RealType) RealType {
    return @sqrt(x);
}

pub fn sin(x: RealType) RealType {
    return @sin(x);
}

pub fn cos(x: RealType) RealType {
    return @cos(x);
}

pub const Vec2 = struct {
    const Self = @This();

    data: @Vector(2, RealType),

    pub fn from(in_x: RealType, in_y: RealType) Self {
        return .{
            .data = .{ in_x, in_y },
        };
    }

    pub fn x(self: Self) RealType {
        return self.data[0];
    }

    pub fn y(self: Self) RealType {
        return self.data[1];
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

    pub fn scale(self: *Self, s: RealType) void {
        self.data *= @splat(s);
    }

    pub fn squareLength(self: Self) RealType {
        return self.x() * self.x() + self.y() * self.y();
    }

    pub fn length(self: Self) RealType {
        return amth.sqrt(self.squareLength());
    }

    pub fn normalize(self: *Self) void {
        self.scale(1 / self.length());
    }

    pub fn dot(l: Self, r: Self) RealType {
        return l.x() * r.x() + l.y() * r.y() + l.z() * r.z();
    }

    /// No extrapolation, clamps t
    pub fn lerp(a: Self, b: Self, t: RealType) Self {
        const l = amth.clamp(t, 0.0, 1.0);
        return Self{
            .data = .{
                (1 - l) * a.x() + l * b.x(),
                (1 - l) * a.y() + l * b.y(),
            },
        };
    }
};

pub const Vec3 = struct {
    const Self = @This();

    data: @Vector(3, RealType),

    pub fn from(in_x: RealType, in_y: RealType, in_z: RealType) Self {
        return .{
            .data = .{ in_x, in_y, in_z },
        };
    }

    pub fn x(self: Self) RealType {
        return self.data[0];
    }

    pub fn y(self: Self) RealType {
        return self.data[1];
    }

    pub fn z(self: Self) RealType {
        return self.data[2];
    }

    pub fn xy(self: Self) Vec2 {
        return Vec2.from(self.x(), self.y());
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

    pub fn scale(self: *Self, s: RealType) void {
        self.data *= @splat(s);
    }

    pub fn squareLength(self: Self) RealType {
        return self.x() * self.x() + self.y() * self.y() + self.z() * self.z();
    }

    pub fn length(self: Self) RealType {
        return amth.sqrt(self.squareLength());
    }

    pub fn normalize(self: *Self) void {
        self.scale(1 / self.length());
    }

    pub fn dot(l: Self, r: Self) RealType {
        return l.x() * r.x() + l.y() * r.y() + l.z() * r.z();
    }

    /// No extrapolation, clamps t
    pub fn lerp(a: Self, b: Self, t: RealType) Self {
        const l = amth.clamp(t, 0.0, 1.0);
        return Self{
            .data = .{
                (1 - l) * a.x() + l * b.x(),
                (1 - l) * a.y() + l * b.y(),
                (1 - l) * a.z() + l * b.z(),
            },
        };
    }

    pub fn cross(l: Self, r: Self) Vec3 {
        return .{
            l.y() * r.z() - l.z() * r.y(),
            l.z() * r.x() - l.x() * r.z(),
            l.x() * r.y() - l.y() * r.x(),
        };
    }
};

pub const Vec4 = struct {
    const Self = @This();

    data: @Vector(4, RealType),

    pub fn from(in_x: RealType, in_y: RealType, in_z: RealType, in_w: RealType) Self {
        return .{
            .data = .{ in_x, in_y, in_z, in_w },
        };
    }

    pub fn x(self: Self) RealType {
        return self.data[0];
    }

    pub fn y(self: Self) RealType {
        return self.data[1];
    }

    pub fn z(self: Self) RealType {
        return self.data[2];
    }

    pub fn w(self: Self) RealType {
        return self.data[3];
    }

    pub fn xyz(self: Self) Vec3 {
        return Vec3.from(self.x(), self.y(), self.z());
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

    pub fn scale(self: *Self, s: RealType) void {
        self.data *= @splat(s);
    }

    pub fn squareLength(self: Self) RealType {
        return self.x() * self.x() + self.y() * self.y() + self.z() * self.z() + self.w() * self.w();
    }

    pub fn length(self: Self) RealType {
        return amth.sqrt(self.squareLength());
    }

    pub fn normalize(self: *Self) void {
        self.scale(1 / self.length());
    }

    pub fn dot(l: Vec4, r: Vec4) RealType {
        return l.x() * r.x() + l.y() * r.y() + l.z() * r.z() + l.w() * r.w();
    }

    /// No extrapolation, clamps t
    pub fn lerp(a: Self, b: Self, t: RealType) Self {
        const l = amth.clamp(t, 0.0, 1.0);
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

pub const Mat4 = struct {
    const Self = @This();

    data: @Vector(16, RealType),

    pub fn diagonal(r: RealType) Mat4 {
        return Mat4{
            .data = .{
                r, 0, 0, 0,
                0, r, 0, 0,
                0, 0, r, 0,
                0, 0, 0, r,
            },
        };
    }

    pub fn identity() Mat4 {
        return Mat4.diagonal(1.0);
    }

    pub fn orthographic(left: RealType, right: RealType, top: RealType, bottom: RealType, near: RealType, far: RealType) Mat4 {
        return Mat4{
            .data = .{
                2 / (right - left), 0,                  0,                 -(right + left) / (right - left),
                0,                  2 / (top - bottom), 0,                 -(top + bottom) / (top - bottom),
                0,                  0,                  -2 / (far - near), -(far + near) / (far - near),
                0,                  0,                  0,                 1.0,
            },
        };
    }

    /// `fov` takes in degrees
    pub fn perspective(fov: RealType, aspect: RealType, near: RealType, far: RealType) Mat4 {
        fov = toRaidans(fov);
        return Mat4{
            .data = .{
                1 / (aspect * @tan(fov / 2)), 0,                 0,                            0,
                0,                            1 / @tan(fov / 2), 0,                            0,
                0,                            0,                 -(far + near) / (far - near), -(2 * far * near) / (far - near),
                0,                            0,                 -1,                           0,
            },
        };
    }

    pub fn translation(x: RealType, y: RealType, z: RealType) Mat4 {
        return Mat4{
            .data = .{
                1, 0, 0, x,
                0, 1, 0, y,
                0, 0, 1, z,
                0, 0, 0, 1,
            },
        };
    }

    /// `angle` takes in degrees
    pub fn rotation(axis: Vec3, angle: RealType) Mat4 {
        var result = Mat4.identity();

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

    pub fn scaling(x: RealType, y: RealType, z: RealType) Mat4 {
        return Mat4{
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

    pub fn scale(self: *Self, s: RealType) void {
        self.data *= @splat(s);
    }

    pub fn multiply(l: Self, r: Self) Self {
        var data: @Vector(16, RealType) = @splat(0.0);

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

        return Mat4{
            .data = data,
        };
    }

    pub fn transpose(self: Self) Self {
        var result = Mat4.identity();

        var row: usize = 0;
        while (row < 4) : (row += 1) {
            var col: usize = 0;
            while (col < 4) : (col += 1) {
                result.data[col * 4 + row] = self.data[row * 4 + col];
            }
        }

        return result;
    }
};
