const Vec = @import("vector.zig").Vec;
const Vec3 = Vec(3, f32);

const Ray = @This();

origin: Vec3,
direction: Vec3,

pub fn from(origin: Vec3, direction: Vec3) Ray {
    return Ray{
        .origin = origin,
        .direction = direction,
    };
}

pub fn at(self: Ray, t: f32) Vec3 {
    return self.origin.add(self.direction.scale(t));
}
