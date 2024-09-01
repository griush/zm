const vec = @import("vector.zig");

pub fn RayBase(comptime T: type) type {
    const type_info = @typeInfo(T);
    comptime switch (type_info) {
        .float => {},
        else => @compileError("Ray is not implemented for type " ++ @typeName(T)),
    };

    return struct {
        const Self = @This();

        const Base = @Vector(3, T);

        origin: Base,
        direction: Base,

        pub fn init(origin: Base, direction: Base) Self {
            return Self{
                .origin = origin,
                .direction = direction,
            };
        }

        pub fn at(self: Self, t: f32) Base {
            return self.origin + vec.scale(self.direction, t);
        }
    };
}
