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
            return true;
        }

        pub fn contains(self: Self, p: Base) bool {
            return (p.x() >= self.min.x() and p.x() <= self.max.x() and
                p.y() >= self.min.y() and p.y() <= self.max.y());
        }
    };
}
