<img src="./res/zm-dark.svg#gh-dark-mode-only" alt="zm Logo" width="400px">
<img src="./res/zm-light.svg#gh-light-mode-only" alt="zm Logo" width="400px">

![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/griush/zm/ci.yaml?style=flat&logo=github&label=CI)

# zm
Fast, Zig math library, fully cross-platform.

## Usage
> [!NOTE]
> This library is tracking Zig's master branch. Last tested with `0.14.0-dev.1002+71a27ebd8`.

Run `zig fetch --save git+https://github.com/griush/zm` on the directory of your `build.zig` and `build.zig.zon`.

Then in the `build.zig` add:
```zig
const zm = b.dependency("zm", .{});
exe.root_module.addImport("zm", zm.module("zm"));
```
Now, in your code, you can use:
```zig
const zm = @import("zm");
```

### Getting Started
For a full example of the usage along with Zig's build system see: [example](/example/).

Simple example for game development.
```zig
const zm = @import("zm");
const std = @import("std");

pub fn main() !void {
    // Initialize window (with GLFW for example)

    // Create OpenGL/Vulkan... context

    const projection = zm.Mat4.perspective(zm.toRadians(60.0), 16.0 / 9.0, 0.05, 100.0);
    const view = zm.Mat4.translation(0.0, 0.75, 5.0);
    const view_proj = projection.multiply(view);

    // Upload data to shader using `&view_proj`
    gl.NamedBufferSubData(ubo, 0, @sizeOf(zm.Mat4), &view_proj);
    
    // Render loop

    // Cleanup
}
```

You can also see a full, working example  [here](https://github.com/griush/zig-opengl-example).

## Benchmarks
See [benchmarks](/test/benchmark.zig).
