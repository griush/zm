# arion-math
SIMD math library module for arion engine

## Usage
Add this URL to dependencies in the `build.zig.zon`:

`https://github.com/griush/arion-math/archive/refs/heads/master.tar.gz`

Then in the `build.zig` add:
```zig
const amth = b.dependency("arion-math", .{});
exe.root_module.addImport("amth", amth.module("arion-math"));
```
Now, in your code, you can use:
```zig
const amth = @import("amth");
```
