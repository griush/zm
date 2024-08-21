const std = @import("std");

pub const VecComponent = enum { x, y, z, w };

pub fn Vec2(Element: type) type {
    return struct {
        pub const dimensions = 2;
        const Base = @Vector(dimensions, Element);

        const Self = @This();

        const Generic = VecGeneric(Element, Self);

        v: Base,

        pub inline fn from(xs: Element, ys: Element) Self {
            return .{ .v = .{ xs, ys } };
        }

        pub inline fn x(v: Self) Element {
            return v.v[0];
        }
        pub inline fn y(v: Self) Element {
            return v.v[1];
        }

        pub const splat = Generic.splat;
        pub const zero = Generic.zero;
        pub const add = Generic.add;
        pub const sub = Generic.sub;
        pub const neg = Generic.neg;
        pub const mul = Generic.mul;
        pub const scale = Generic.scale;
        pub const dot = Generic.dot;
        pub const lenSq = Generic.lenSq;
        pub const len = Generic.len;
        pub const normalized = Generic.normalized;
        pub const lerp = Generic.lerp;
        pub const distance = Generic.distance;
        pub const angle = Generic.angle;
    };
}

pub fn Vec3(Element: type) type {
    return struct {
        pub const dimensions = 3;
        const Base = @Vector(dimensions, Element);

        const Self = @This();

        const Generic = VecGeneric(Element, Self);

        v: Base,

        pub inline fn from(xs: Element, ys: Element, zs: Element) Self {
            return .{ .v = .{ xs, ys, zs } };
        }

        pub inline fn right() Self {
            return .{ .v = .{ 1, 0, 0 } };
        }

        pub inline fn up() Self {
            return .{ .v = .{ 0, 1, 0 } };
        }

        pub inline fn forward() Self {
            return .{ .v = .{ 0, 0, 1 } };
        }

        pub inline fn left() Self {
            return .{ .v = .{ -1, 0, 0 } };
        }

        pub inline fn down() Self {
            return .{ .v = .{ 0, -1, 0 } };
        }

        pub inline fn back() Self {
            return .{ .v = .{ 0, 0, -1 } };
        }

        pub inline fn x(v: Self) Element {
            return v.v[0];
        }
        pub inline fn y(v: Self) Element {
            return v.v[1];
        }
        pub inline fn z(v: Self) Element {
            return v.v[2];
        }

        pub inline fn swizzle(
            v: *const Self,
            xc: VecComponent,
            yc: VecComponent,
            zc: VecComponent,
        ) Self {
            return .{ .v = @shuffle(Element, v.v, undefined, [3]Element{
                @intFromEnum(xc),
                @intFromEnum(yc),
                @intFromEnum(zc),
            }) };
        }

        /// Calculates the cross product between vector a and b.
        /// This can be done only in 3D and required inputs are Vec3.
        pub inline fn cross(a: Self, b: Self) Self {
            // https://gamemath.com/book/vectors.html#cross_product
            const s1 = a.swizzle(.y, .z, .x)
                .mul(b.swizzle(.z, .x, .y));
            const s2 = a.swizzle(.z, .x, .y)
                .mul(b.swizzle(.y, .z, .x));
            return s1.sub(s2);
        }

        pub const splat = Generic.splat;
        pub const zero = Generic.zero;
        pub const add = Generic.add;
        pub const sub = Generic.sub;
        pub const neg = Generic.neg;
        pub const mul = Generic.mul;
        pub const scale = Generic.scale;
        pub const dot = Generic.dot;
        pub const lenSq = Generic.lenSq;
        pub const len = Generic.len;
        pub const normalized = Generic.normalized;
        pub const lerp = Generic.lerp;
        pub const distance = Generic.distance;
        pub const angle = Generic.angle;
    };
}

pub fn Vec4(Element: type) type {
    return struct {
        pub const dimensions = 4;
        const Base = @Vector(dimensions, Element);

        const Self = @This();

        const Generic = VecGeneric(Element, Self);

        v: Base,

        pub inline fn from(xs: Element, ys: Element, zs: Element, ws: Element) Self {
            return .{ .v = .{ xs, ys, zs, ws } };
        }

        pub inline fn x(v: Self) Element {
            return v.v[0];
        }
        pub inline fn y(v: Self) Element {
            return v.v[1];
        }
        pub inline fn z(v: Self) Element {
            return v.v[2];
        }
        pub inline fn w(v: Self) Element {
            return v.v[3];
        }

        pub const splat = Generic.splat;
        pub const zero = Generic.zero;
        pub const add = Generic.add;
        pub const sub = Generic.sub;
        pub const neg = Generic.neg;
        pub const mul = Generic.mul;
        pub const scale = Generic.scale;
        pub const dot = Generic.dot;
        pub const lenSq = Generic.lenSq;
        pub const len = Generic.len;
        pub const normalized = Generic.normalized;
        pub const lerp = Generic.lerp;
        pub const distance = Generic.distance;
        pub const angle = Generic.angle;
    };
}

fn VecGeneric(Element: type, Vector: type) type {
    return struct {
        pub inline fn splat(scalar: Element) Vector {
            return .{ .v = @splat(scalar) };
        }

        pub inline fn zero() Vector {
            return .{ .v = @splat(0.0) };
        }

        /// Element-wise addition
        pub inline fn add(lhs: Vector, rhs: Vector) Vector {
            return .{ .v = lhs.v + rhs.v };
        }

        /// Element-wise subtraction
        pub inline fn sub(lhs: Vector, rhs: Vector) Vector {
            return .{ .v = lhs.v - rhs.v };
        }

        /// Element-wise negate
        pub inline fn neg(v: Vector) Vector {
            return .{ .v = -v.v };
        }

        /// Element-wise multiplication.
        pub inline fn mul(a: Vector, b: Vector) Vector {
            return .{ .v = a.v * b.v };
        }

        /// Scale the vector by the given scalar
        pub inline fn scale(v: Vector, s: Element) Vector {
            return .{ .v = v.v * Vector.splat(s).v };
        }

        /// Calculates the dot product between vector a and b and returns scalar.
        pub inline fn dot(a: Vector, b: Vector) Element {
            return @reduce(.Add, a.v * b.v);
        }

        pub inline fn lenSq(v: Vector) Element {
            return @reduce(.Add, v.v * v.v);
        }

        pub inline fn len(v: Vector) Element {
            return @sqrt(v.lenSq());
        }

        pub inline fn normalized(v: Vector) Vector {
            return v.scale(1.0 / v.len());
        }

        pub fn lerp(a: Vector, b: Vector, t: Element) Vector {
            return .{ .v = @mulAdd(@Vector(Vector.dimensions, Element), b.v - a.v, @splat(t), a.v) };
        }

        /// Returns the distance between two points
        pub fn distance(a: Vector, b: Vector) Element {
            return b.sub(a).len();
        }

        /// Returns the angle (in radians) between two vectors
        pub fn angle(a: Vector, b: Vector) Element {
            const len_a = a.len();
            const len_b = b.len();
            const dot_product = a.dot(b);
            return std.math.acos(dot_product / (len_a * len_b));
        }
    };
}
