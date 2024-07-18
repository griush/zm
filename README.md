# zm
SIMD math library

## Usage
> [!NOTE]  
> This library is tracking Zig's master branch. Last tested with `0.14.0-dev.363+c3faae6bf`.

Add this dependency in the `build.zig.zon`:

```zig
.zm = .{
    .url = "https://github.com/griush/zm/archive/refs/heads/master.tar.gz"
    .hash = "hash here",
},

```

Then in the `build.zig` add:
```zig
const zm = b.dependency("zm", .{});
exe.root_module.addImport("zm", zm.module("root"));
```
Now, in your code, you can use:
```zig
const zm = @import("zm");
```
