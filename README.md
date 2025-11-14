<img src="https://raw.githubusercontent.com/griush/resources/f5f9659dd5c4d18d63ff9bc2e67b8feee874e482/logos/zm-dark.svg#gh-dark-mode-only" alt="zm Logo" width="400px">
<img src="https://raw.githubusercontent.com/griush/resources/f5f9659dd5c4d18d63ff9bc2e67b8feee874e482/logos/zm-light.svg#gh-light-mode-only" alt="zm Logo" width="400px">

![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/griush/zm/ci.yaml?style=flat&logo=github&label=CI)

# zm - Fast math library
zm is a Zig math library. It is fast and easy to use.

## Usage
> [!NOTE]
> This library is tracking Zig's master branch. Last tested with `0.16.0-dev.164+bc7955306`.
> It may not compile with newer or older versions.

Run `zig fetch --save git+https://github.com/griush/zm` on the directory of your `build.zig` and `build.zig.zon`.

Then in the `build.zig` add:
```zig
const zm = b.dependency("zm", .{
    .target = target,
    .optimize = optimize,
});
module.addImport("zm", zm.module("zm"));
```
Now, in your code, you can use:
```zig
const zm = @import("zm");
```

### Example
Demo using the library (incomplete) [demo](/examples/demo.zig).

## Benchmarks
See [benchmarks](/test/benchmark.zig).
