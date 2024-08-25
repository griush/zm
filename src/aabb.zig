const vec = @import("vector.zig");

pub fn AABBBase(dimensions: comptime_int, Element: type) type {
    return struct {
        const Base: type = switch (dimensions) {
            2 => if (Element == f32) vec.Vec2f else vec.Vec2d,
            3 => if (Element == f32) vec.Vec3f else vec.Vec3d,
            else => @compileError("invalid AABB dimensions"),
        };

        const Self = @This();

        min: Base,
        max: Base,

        pub fn init(min: Base, max: Base) Self {
            return Self{
                .min = min,
                .max = max,
            };
        }

        pub fn intersects(a: Self, b: Self) bool {
            if (a.max[0] < b.min[0] or a.min[0] > b.max[0]) return false;
            if (a.max[1] < b.min[1] or a.min[1] > b.max[1]) return false;
            if (dimensions == 3) {
                if (a.max[2] < b.min[2] or a.min[2] > b.max[2]) return false;
            }
            return true;
        }

        /// If `p` is at the edge, returns `false`
        pub fn containsPoint(self: Self, p: Base) bool {
            if (p[0] < self.min[0] or p[0] > self.max[0]) return false;
            if (p[1] < self.min[1] or p[1] > self.max[1]) return false;
            if (dimensions == 3) {
                if (p[2] < self.min[2] or p[2] > self.max[2]) return false;
            }
            return true;
        }

        pub fn containsAABB(self: Self, other: Self) bool {
            return self.containsPoint(other.min) and self.containsPoint(other.max);
        }

        /// Returns the center of the AABB
        pub fn center(self: Self) Base {
            return vec.scale(self.min + self.max, 0.5);
        }

        /// Returns the size of the AABB
        pub fn size(self: Self) Base {
            return self.max - self.min;
        }
    };
}
