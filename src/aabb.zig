const vec = @import("vector.zig");

pub fn AABBBase(dimensions: comptime_int, Element: type) type {
    return struct {
        const Base: type = switch (dimensions) {
            2 => vec.Vec2(Element),
            3 => vec.Vec3(Element),
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
            if (a.max.x() < b.min.x() or a.min.x() > b.max.x()) return false;
            if (a.max.y() < b.min.y() or a.min.y() > b.max.y()) return false;
            comptime if (dimensions == 3) {
                if (a.max.z() < b.min.z() or a.min.z() > b.max.z()) return false;
            };
            return true;
        }

        /// If `p` is at the edge, returns `false`
        pub fn containsPoint(self: Self, p: Base) bool {
            if (p.x() < self.min.x() or p.x() > self.max.x()) return false;
            if (p.y() < self.min.y() or p.y() > self.max.y()) return false;
            comptime if (dimensions == 3) {
                if (p.z() < self.min.z() or p.z() > self.max.z()) return false;
            };
            return true;
        }

        pub fn containsAABB(self: Self, other: Self) bool {
            return self.containsPoint(other.min) and self.containsPoint(other.max);
        }

        /// Returns the center of the AABB
        pub fn center(self: Self) Base {
            return (self.min.add(self.max)).scale(0.5);
        }

        /// Returns the size of the AABB
        pub fn size(self: Self) Base {
            return self.max.sub(self.min);
        }
    };
}
