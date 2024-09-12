const std = @import("std");

pub const Vec2f = @Vector(2, f32);
pub const Vec2d = @Vector(2, f64);
pub const Vec3f = @Vector(3, f32);
pub const Vec3d = @Vector(3, f64);
pub const Vec4f = @Vector(4, f32);
pub const Vec4d = @Vector(4, f64);

pub fn dimensions(T: type) comptime_int {
    return @typeInfo(T).vector.len;
}

pub fn VecElement(T: type) type {
    return @typeInfo(T).vector.child;
}

pub fn zero(l: comptime_int, Element: type) @Vector(l, Element) {
    return @splat(0);
}

pub fn right(Element: type) @Vector(3, Element) {
    return @Vector(3, Element){ 1, 0, 0 };
}

pub fn up(Element: type) @Vector(3, Element) {
    return @Vector(3, Element){ 0, 1, 0 };
}

pub fn forward(Element: type) @Vector(3, Element) {
    return @Vector(3, Element){ 0, 0, 1 };
}

pub fn xyz(self: anytype) @Vector(3, VecElement(@TypeOf(self))) {
    return @Vector(3, VecElement(@TypeOf(self))){ self[0], self[1], self[2] };
}

pub fn xy(self: anytype) @Vector(2, VecElement(@TypeOf(self))) {
    return @Vector(2, VecElement(@TypeOf(self))){ self[0], self[1] };
}

pub fn scale(self: anytype, scalar: VecElement(@TypeOf(self))) @TypeOf(self) {
    return self * @as(@TypeOf(self), @splat(scalar));
}

pub fn dot(self: anytype, other: @TypeOf(self)) VecElement(@TypeOf(self)) {
    return @reduce(.Add, self * other);
}

pub fn lenSq(self: anytype) VecElement(@TypeOf(self)) {
    return @reduce(.Add, self * self);
}

pub fn len(self: anytype) VecElement(@TypeOf(self)) {
    return @sqrt(@reduce(.Add, self * self));
}

pub fn normalize(self: anytype) @TypeOf(self) {
    return self / @as(@TypeOf(self), @splat(len(self)));
}

pub fn cross(self: anytype, other: @TypeOf(self)) @TypeOf(self) {
    if (dimensions(@TypeOf(self)) != 3) @compileError("cross is only defined for vectors of length 3.");
    return @TypeOf(self){
        self[1] * other[2] - self[2] * other[1],
        self[2] * other[0] - self[0] * other[2],
        self[0] * other[1] - self[1] * other[0],
    };
}

/// Returns the distance between two points.
pub fn distance(self: anytype, other: @TypeOf(self)) VecElement(@TypeOf(self)) {
    return len(other - self);
}

/// Returns the angle between two vectors in radians.
pub fn angle(self: anytype, other: @TypeOf(self)) VecElement(@TypeOf(self)) {
    const len_a = len(self);
    const len_b = len(other);
    const dot_product = dot(self, other);
    return std.math.acos(dot_product / (len_a * len_b));
}

pub fn lerp(a: anytype, b: anytype, t: VecElement(@TypeOf(a, b))) @TypeOf(a, b) {
    const T = @TypeOf(a, b);
    return @mulAdd(T, b - a, @as(T, @splat(t)), a);
}

/// Reflects `self` along `normal`. `normal` must be normalized.
pub fn reflect(self: anytype, normal: anytype) @TypeOf(self, normal) {
    return self - @as(@TypeOf(self, normal), @splat(2.0 * dot(self, normal))) * normal;
}
