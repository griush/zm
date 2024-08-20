const Vec = @import("vector.zig").Vec;

pub fn RayBase(comptime T: type) type {
    const type_info = @typeInfo(T);
    comptime switch (type_info) {
        .Float => {},
        else => @compileError("Ray only supports floating point type. Ray is not implemented for type " ++ @typeName(T)),
    };

    return struct {
        const Self = @This();

        const DataType = Vec(3, T);

        origin: DataType,
        direction: DataType,

        pub fn from(origin: DataType, direction: DataType) Self {
            return Self{
                .origin = origin,
                .direction = direction,
            };
        }

        pub fn at(self: Self, t: f32) DataType {
            return self.origin.add(self.direction.scale(t));
        }
    };
}
