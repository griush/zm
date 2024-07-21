# zm
![GitHub License](https://img.shields.io/github/license/griush/zm?style=for-the-badge)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/griush/zm/.github%2Fworkflows%2Fci.yaml?branch=master&style=for-the-badge)
![GitHub repo size](https://img.shields.io/github/repo-size/griush/zm?style=for-the-badge&logo=github)
![GitHub Repo stars](https://img.shields.io/github/stars/griush/zm?style=for-the-badge&logo=github&color=gold)

SIMD math library

## Usage
> [!NOTE]
> This library is tracking Zig's master branch. Last tested with `0.14.0-dev.367+a57479afc`.

Add this dependency in the `build.zig.zon`:

```zig
.zm = .{
    .url = "https://github.com/griush/zm/archive/refs/heads/master.tar.gz"
},

```
Run `zig build` and it will give a hash. Append id bellow the URL.

Or, run `zig fetch --save git+https://github.com/griush/zm`.

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
See [example](/example/)
