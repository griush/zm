const RealType = f32;

/// Vec2 type
pub const Vec2 = @Vector(2, RealType);

/// Vec3 type
pub const Vec3 = @Vector(3, RealType);

/// Vec4 type
pub const Vec4 = @Vector(4, RealType);

/// Scales a vec of given type
pub fn scale(comptime T: type, v: *T, s: RealType) void {
    v.* *= @splat(s);
}
