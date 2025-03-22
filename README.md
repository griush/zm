<img src="https://raw.githubusercontent.com/griush/resources/f5f9659dd5c4d18d63ff9bc2e67b8feee874e482/logos/zm-dark.svg#gh-dark-mode-only" alt="zm Logo" width="400px">
<img src="https://raw.githubusercontent.com/griush/resources/f5f9659dd5c4d18d63ff9bc2e67b8feee874e482/logos/zm-light.svg#gh-light-mode-only" alt="zm Logo" width="400px">

![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/griush/zm/ci.yaml?style=flat&logo=github&label=CI)

# zm - Fast math library
zm is a Zig math library. It is fast, easy to use and cross-platform.

## Usage
> [!NOTE]
> This library is tracking Zig's master branch. Last tested with `0.15.0-dev.77+aa8aa6625`.
> It may not compile with newer or older versions.

Run `zig fetch --save git+https://github.com/griush/zm` on the directory of your `build.zig` and `build.zig.zon`.

Then in the `build.zig` add:
```zig
const zm = b.dependency("zm", .{});
exe_mod.addImport("zm", zm.module("zm"));
```
Now, in your code, you can use:
```zig
const zm = @import("zm");
```

### Getting Started
For an example using Zig's build system see: [example](/example/).
There is a working example using OpenGL and GLFW [here](https://github.com/griush/zig-opengl-example).

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

    // Upload data
    gl.NamedBufferSubData(ubo, 0, @sizeOf(zm.Mat4), &view_proj);

    // Render loop

    // Cleanup
}
```

## Benchmarks
See [benchmarks](/test/benchmark.zig).
