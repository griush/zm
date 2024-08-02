# zm
![Codacy grade](https://img.shields.io/codacy/grade/2b4cfca0999e48028fe6b83cf4002496?style=for-the-badge)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/griush/zm/.github%2Fworkflows%2Fci.yaml?branch=master&style=for-the-badge)

SIMD math library fully cross-platform.

## Usage
> [!NOTE]
> This library is tracking Zig's master branch. Last tested with `0.14.0-dev.781+f03d54f06`.

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

### Example
See [example](/example/).

## Benchmarks
See [benchmarks](/src/benchmark.zig).
