const RealType = f32;

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
        return @sqrt(self.squareLength());
    }

    pub fn normalize(self: *Self) void {
        self.scale(1 / self.length());
    }

    pub fn dot(l: Vec2, r: Vec2) RealType {
        return l.x() * r.x() + l.y() * r.y() + l.z() * r.z();
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
        return @sqrt(self.squareLength());
    }

    pub fn normalize(self: *Self) void {
        self.scale(1 / self.length());
    }

    pub fn dot(l: Vec3, r: Vec3) RealType {
        return l.x() * r.x() + l.y() * r.y() + l.z() * r.z();
    }

    pub fn cross(l: Vec3, r: Vec3) Vec3 {
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
        return @sqrt(self.squareLength());
    }

    pub fn normalize(self: *Self) void {
        self.scale(1 / self.length());
    }

    pub fn dot(l: Vec4, r: Vec4) RealType {
        return l.x() * r.x() + l.y() * r.y() + l.z() * r.z() + l.w() * r.w();
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

    pub fn orthographic(l: RealType, r: RealType, t: RealType, b: RealType, n: RealType, f: RealType) Mat4 {
        return Mat4{
            .data = .{
                2 / (r - l), 0,           0,            -(r + l) / (r - l),
                0,           2 / (t - b), 0,            -(t + b) / (t - b),
                0,           0,           -2 / (f - n), -(f + n) / (f - n),
                0,           0,           0,            1.0,
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
};
