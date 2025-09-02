const vec = @import("vec.zig");

pub fn AABB(dimensions: comptime_int, Element: type) type {
    return struct {
        const V: type = switch (dimensions) {
            2 => if (Element == f32) vec.Vec2f else vec.Vec2,
            3 => if (Element == f32) vec.Vec3f else vec.Vec3,
            else => @compileError("invalid AABB dimensions"),
        };

        const Self = @This();

        min: V,
        max: V,

        pub fn init(min: V, max: V) Self {
            return Self{
                .min = min,
                .max = max,
            };
        }

        /// Checks if an AABB intersects with another AABB.
        pub fn intersects(a: Self, b: Self) bool {
            if (a.max.data[0] < b.min.data[0] or a.min.data[0] > b.max.data[0]) return false;
            if (a.max.data[1] < b.min.data[1] or a.min.data[1] > b.max.data[1]) return false;
            if (dimensions == 3) {
                if (a.max.data[2] < b.min.data[2] or a.min.data[2] > b.max.data[2]) return false;
            }
            return true;
        }

        /// Returns `true` if `p` is in the AABB.
        /// If `p` is at the edge, returns `true`.
        pub fn containsPoint(self: Self, p: V) bool {
            if (p.data[0] < self.min.data[0] or p.data[0] > self.max.data[0]) return false;
            if (p.data[1] < self.min.data[1] or p.data[1] > self.max.data[1]) return false;
            if (dimensions == 3) {
                if (p.data[2] < self.min.data[2] or p.data[2] > self.max.data[2]) return false;
            }
            return true;
        }

        /// Returns `true` if `other` is fully contained inside `self`.
        pub fn containsAABB(self: Self, other: Self) bool {
            return self.containsPoint(other.min) and self.containsPoint(other.max);
        }

        /// Returns the center of the AABB.
        pub fn center(self: Self) V {
            return self.min.add(self.max).scale(0.5);
        }

        /// Returns a vector with the size of the AABB.
        pub fn size(self: Self) V {
            return self.max.sub(self.min);
        }
    };
}
