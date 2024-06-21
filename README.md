# arion-math
SIMD math library module for arion engine

## Usage
Add this dependency in the `build.zig.zon`:

```zig
.arion_math = .{
    .url = "https://github.com/griush/arion-math/archive/refs/heads/master.tar.gz"
    .hash = "hash here",
    .lazy = true,
},

```

Then in the `build.zig` add:
```zig
const amth = b.dependency("arion_math", .{});
exe.root_module.addImport("amth", amth.module("root"));
```
Now, in your code, you can use:
```zig
const amth = @import("amth");
```
