const vec = @import("vec.zig");

pub fn Ray(comptime T: type) type {
    const type_info = @typeInfo(T);
    comptime switch (type_info) {
        .float => {},
        else => @compileError("Ray is not implemented for type " ++ @typeName(T)),
    };

    return struct {
        const Self = @This();

        const V = vec.Vec(3, T);

        origin: V,
        direction: V,

        pub fn init(origin: V, direction: V) Self {
            return Self{
                .origin = origin,
                .direction = direction,
            };
        }

        pub fn at(self: Self, t: T) V {
            return self.origin.add(self.direction.scale(t));
        }
    };
}
