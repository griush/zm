# arion-math
SIMD math library module for arion engine

## Usage
Add this URL to dependencies in the `build.zig.zon`: `https://github.com/griush/arion-math/archive/refs/heads/master.tar.gz`

Then in the `build.zig` add:
```zig
const amth = b.dependency("amth", .{});
exe.root_module.addImport("amth", amth.module("root"));
```
Now, in your code use;
```zig
const amth = @import("amth");
```
