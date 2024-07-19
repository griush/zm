# zm
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/griush/zm/.github%2Fworkflows%2Fci.yaml?branch=master&style=for-the-badge)
![GitHub repo size](https://img.shields.io/github/repo-size/griush/zm?style=for-the-badge&logo=github)
![GitHub Repo stars](https://img.shields.io/github/stars/griush/zm?style=for-the-badge&logo=github&color=gold)

SIMD math library

## Usage
> [!NOTE]
> This library is tracking Zig's master branch. Last tested with `0.14.0-dev.363+c3faae6bf`.

Add this dependency in the `build.zig.zon`:

```zig
.zm = .{
    .url = "https://github.com/griush/zm/archive/refs/heads/master.tar.gz"
},

```
Run `zig build` and it will give a hash. Append id bellow the URL.

Then in the `build.zig` add:
```zig
const zm = b.dependency("zm", .{});
exe.root_module.addImport("zm", zm.module("zm"));
```
Now, in your code, you can use:
```zig
const zm = @import("zm");
```

### Example
```zig
const zm = @import("zm");

pub fn main() !void {
    // Base type
    const Vec2OfU16 = zm.Vec2Base(u16);
    const vec = Vec2OfU16.from(3, 1);
    // ... use vec

    // Built-in vec and mat types
    // [Vec/Mat]X -> [Vec/Mat]XBase(f32)
    // [Vec/Mat]Xd -> [Vec/Mat]XBase(f64);
    // [Vec/Mat]Xi -> [Vec/Mat]XBase(i32);
    const vec2 = zm.Vec2.from(0.3, -1.5); // Vec2 of 'f32'

    // Projection matrices
    const camera = zm.Mat4.perspective(60.0, 16.0 / 9.0, 0.05, 100.0);

    // Essential operations
    const inverse = camera.inverse();
}
```
