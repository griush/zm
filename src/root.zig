const std = @import("std");

const RealType = f32;

/// Vec2 type
pub const Vec2 = @Vector(2, RealType);

/// Vec3 type
pub const Vec3 = @Vector(3, RealType);

/// Vec4 type
pub const Vec4 = @Vector(4, RealType);

/// Mat4 type
pub const Mat4 = @Vector(16, RealType);

pub fn scaleVec2(v: *Vec2, s: RealType) void {
    v.* *= @splat(s);
}

pub fn scaleVec3(v: *Vec3, s: RealType) void {
    v.* *= @splat(s);
}

pub fn scaleVec4(v: *Vec4, s: RealType) void {
    v.* *= @splat(s);
}

pub fn scaleMat4(m: *Mat4, s: RealType) void {
    m.* *= @splat(s);
}

pub fn squareLengthVec2(v: Vec2) RealType {
    return v[0] * v[0] + v[1] * v[1];
}

pub fn squareLengthVec3(v: Vec3) RealType {
    return v[0] * v[0] + v[1] * v[1] + v[2] * v[2];
}

pub fn squareLengthVec4(v: Vec4) RealType {
    return v[0] * v[0] + v[1] * v[1] + v[2] * v[2] + v[3] * v[3];
}

pub fn lengthVec2(v: Vec2) RealType {
    return @sqrt(squareLengthVec2(v));
}

pub fn lengthVec3(v: Vec3) RealType {
    return @sqrt(squareLengthVec3(v));
}

pub fn lengthVec4(v: Vec4) RealType {
    return @sqrt(squareLengthVec4(v));
}

pub fn normalizeVec2(v: *Vec2) void {
    scaleVec2(v, 1 / lengthVec2(v.*));
}

pub fn normalizeVec3(v: *Vec3) void {
    scaleVec3(v, 1 / lengthVec3(v.*));
}

pub fn normalizeVec4(v: *Vec4) void {
    scaleVec4(v, 1 / lengthVec4(v.*));
}

pub fn dotVec2(l: Vec2, r: Vec2) RealType {
    return l[0] * r[0] + l[1] * r[1];
}

pub fn dotVec3(l: Vec3, r: Vec3) RealType {
    return l[0] * r[0] + l[1] * r[1] + l[2] * r[2];
}

pub fn dotVec4(l: Vec4, r: Vec4) RealType {
    return l[0] * r[0] + l[1] * r[1] + l[2] * r[2] + l[3] * r[3];
}

pub fn cross(l: Vec3, r: Vec3) Vec3 {
    return .{
        l[1] * r[2] - l[2] * r[1],
        l[2] * r[0] - l[0] * r[2],
        l[0] * r[1] - l[1] * r[0],
    };
}

pub fn diagonalMat4(r: RealType) Mat4 {
    return Mat4{
        r, 0, 0, 0,
        0, r, 0, 0,
        0, 0, r, 0,
        0, 0, 0, r,
    };
}

pub fn identity() Mat4 {
    return diagonalMat4(1.0);
}

pub fn orthographic(l: RealType, r: RealType, t: RealType, b: RealType, n: RealType, f: RealType) Mat4 {
    return Mat4{
        2 / (r - l), 0,           0,            -(r + l) / (r - l),
        0,           2 / (t - b), 0,            -(t + b) / (t - b),
        0,           0,           -2 / (f - n), -(f + n) / (f - n),
        0,           0,           0,            1.0,
    };
}
