const Vec3 = @import("vector.zig").Vec3;

pub fn RayBase(comptime T: type) type {
    const type_info = @typeInfo(T);
    comptime switch (type_info) {
        .Float => {},
        else => @compileError("Ray only supports floating point type. Ray is not implemented for type " ++ @typeName(T)),
    };

    return struct {
        const Self = @This();

        const Base = Vec3(T);

        origin: Base,
        direction: Base,

        pub fn init(origin: Base, direction: Base) Self {
            return Self{
                .origin = origin,
                .direction = direction,
            };
        }

        pub fn at(self: Self, t: f32) Base {
            return self.origin.add(self.direction.scale(t));
        }
    };
}
