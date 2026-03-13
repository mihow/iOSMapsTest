# iOSMapsTest — MapLibre Build System Research Results

## Date: 2026-03-12

## MapLibre Native Repository Analysis

Repository cloned to `~/Projects/maplibre-native` (shallow clone, HEAD of main branch).

### OpenGL Build Flags Found

The CMake build system supports four mutually exclusive rendering backends:

- `MLN_WITH_OPENGL` (default: OFF)
- `MLN_WITH_METAL` (default: OFF)
- `MLN_WITH_VULKAN` (default: OFF)
- `MLN_WITH_WEBGPU` (default: OFF)

Exactly one must be enabled. Validation in `cmake/validate-backend-options.cmake`.

When `MLN_WITH_OPENGL=ON`, `cmake/opengl.cmake` configures:
- Compile definition: `MLN_RENDER_BACKEND_OPENGL=1`
- Full set of GL renderer source files in `src/mbgl/gl/` (~30+ .cpp files)
- GL shader implementations in `src/mbgl/shaders/gl/`
- Drawable renderer GL sources

The OpenGL renderer is actively maintained -- it has shader files, buffer allocators,
texture management, and the full drawable pipeline, not just stubs.

### CMake Presets Available

Presets: ios, ios-metal, ios-webgpu-dawn, ios-webgpu-wgpu, macos, macos-metal,
macos-metal-xcode, macos-vulkan, macos-vulkan-xcode, macos-metal-node,
macos-webgpu-dawn, macos-webgpu-wgpu, linux, linux-opengl, linux-vulkan,
linux-webgpu-dawn, linux-webgpu-wgpu, android-webgpu-dawn, android-webgpu-wgpu,
linux-opengl-node, windows, windows-opengl, windows-opengl-node, windows-egl,
windows-vulkan, windows-arm64, windows-arm64-opengl, windows-arm64-opengl-node,
windows-arm64-vulkan.

**No `ios-opengl` preset exists.** OpenGL presets are only provided for Linux and Windows.
However, the `ios` base preset can theoretically be inherited with `MLN_WITH_OPENGL=ON`.

### Bazel Renderer Configs

Bazel has a `config_setting` named `:drawable_renderer` which selects OpenGL sources:
- `MLN_OPENGL_SOURCE`, `MLN_DRAWABLES_GL_SOURCE` compiled
- `MLN_OPENGL_HEADERS`, `MLN_DRAWABLES_GL_HEADERS` included

iOS Bazel files (`platform/ios/bazel/files.bzl`) explicitly list:
- `MLN_IOS_PUBLIC_OBJCPP_OPENGL_SOURCE = ["src/MLNMapView+OpenGL.mm"]`
- `src/MLNMapView+OpenGL.h` in private headers

### OpenGL ES Version Requirements

**MapLibre requires OpenGL ES 3.0.** Evidence:

1. `platform/ios/src/MLNMapView+OpenGL.mm:113` creates an ES3 context:
   `resource.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3]`

2. `platform/darwin/src/headless_backend_eagl.mm` also uses `kEAGLRenderingAPIOpenGLES3`

3. All GLSL shaders use `#version 300 es` (see `src/mbgl/shaders/gl/shader_program_gl.cpp:126`
   and `src/mbgl/shaders/gl/legacy/program_base.hpp:59`)

4. Uses ES 3.0 functions like `glMapBufferRange` (in `src/mbgl/gl/buffer_allocator.cpp`)

### iOS Simulator OpenGL ES 3.0 Support

The iOS Simulator SDK includes ES3 headers:
- `OpenGLES.framework/Headers/ES3/` directory exists
- `kEAGLRenderingAPIOpenGLES3 = 3` is defined in `EAGL.h`
- GLKit.framework is present

SDK path: `iPhoneSimulator.sdk/System/Library/Frameworks/OpenGLES.framework/`

**Runtime question:** Whether `EAGLContext initWithAPI:kEAGLRenderingAPIOpenGLES3` succeeds
at runtime in a QEMU VM is unknown. Apple deprecated OpenGL ES in iOS 12 but the framework
remains. The iOS Simulator uses software rendering (not GPU), and Apple's software renderer
historically supports ES 3.0 on x86_64 simulators. Our VM runs x86_64 macOS, so the
simulator should use the same software renderer.

### iOS Platform Build Files

The iOS build uses `platform/ios/ios.cmake` which:
- Filters source files based on renderer backend
- When NOT Metal/WebGPU (i.e., OpenGL): keeps OpenGL files, excludes Metal/WebGPU
- Links frameworks: CoreText, CoreImage, CoreGraphics, QuartzCore, UIKit, ImageIO
- Does NOT explicitly link OpenGLES or GLKit (these must be added)

**Critical dependency:** `platform/darwin/darwin.cmake` requires Bazel:
`find_program(BAZEL bazel REQUIRED)` -- needed to generate Darwin style code
(`MLNBackgroundStyleLayer.mm`, etc.) via `bazel build //platform/darwin:generated_code`.
The CMake build requires Bazel as a prerequisite.

### Tool Availability on VM

| Tool | Status |
|------|--------|
| CMake | NOT INSTALLED (not in PATH, not in Xcode.app) |
| Bazel | NOT INSTALLED |
| Ninja | NOT INSTALLED |
| ccache | NOT INSTALLED |
| Homebrew | NOT INSTALLED |
| Xcode | 16.2 installed |
| Disk space | 144 GB free |
| RAM/CPU | 32 GB / 12 cores |

### Submodule Dependencies

The repo uses git submodules for vendors (not initialized in shallow clone):
boost, freetype, harfbuzz, googletest, glslang, etc.
`git submodule update --init --recursive` would be needed.

## Assessment

### Path A (CMake) Viability

**BLOCKED without significant setup.** Requirements:
1. Install CMake >= 3.25 (repo requirement)
2. Install Bazel (required by darwin.cmake for code generation)
3. Install Ninja (used by most presets, though Xcode generator works too)
4. Initialize git submodules
5. Create a custom `ios-opengl` preset (none exists)

Without Homebrew, installing CMake and Bazel is non-trivial. CMake could be installed
from the official `.dmg` installer. Bazel requires a more involved installation.

The CMake path also has a chicken-and-egg problem: it needs Bazel to generate code, so
you effectively need both build systems.

### Path B (Bazel) Viability

**More promising but still needs Bazel installed.** The Bazel build:
- Has explicit iOS OpenGL support (files.bzl lists OpenGL sources)
- Does not depend on CMake
- Handles code generation natively
- Has a `drawable_renderer` config for OpenGL

Installation: Bazel can be installed via the official binary release (no Homebrew needed).
Bazelisk (a Bazel wrapper) is a single binary download.

### Hard Blockers

1. **No build tools installed.** Neither CMake nor Bazel is available on the VM. Homebrew
   is not installed, making tool installation harder (but not impossible via direct downloads).

2. **ES 3.0 runtime support is unverified.** The headers exist, but whether `EAGLContext`
   with ES 3.0 actually works at runtime in the QEMU simulator is unknown. This can only
   be tested after building a test binary. If the software renderer does not support ES 3.0,
   all GL shaders will fail (they require `#version 300 es`).

3. **GLKit is deprecated.** MapLibre iOS OpenGL path uses `GLKView` and `GLKViewDelegate`,
   which are deprecated since iOS 12 and may be removed in future Xcode versions. Currently
   still present in Xcode 16.2 SDK.

4. **Submodules not initialized.** The shallow clone does not include vendor dependencies.
   A full `git submodule update --init --recursive` is needed (potentially large download).

### No Absolute Blockers Found

The OpenGL rendering path is maintained, the iOS platform has OpenGL source files, ES3
headers exist in the simulator SDK. The main obstacles are tooling installation.

### Recommended Next Steps

1. **Quick ES 3.0 runtime test** -- Write a minimal ObjC test app that creates an
   `EAGLContext` with `kEAGLRenderingAPIOpenGLES3` and checks if it returns nil. This can
   be done with plain `xcodebuild` (no CMake/Bazel needed) and answers the critical question
   of whether OpenGL ES 3.0 works in our QEMU simulator.

2. **If ES 3.0 works:** Install Bazelisk (single binary, ~10MB) and attempt the Bazel build
   with `--//:renderer=drawable` (OpenGL). The Bazel path is self-contained and does not need
   CMake.

3. **If ES 3.0 does not work:** The MapLibre OpenGL path is definitively blocked. Fall back
   to the Leaflet.js/WKWebView approach used by FieldWalk.

---

## Runtime OpenGL ES Test — 2026-03-13

### Test Setup

A minimal Swift SPM project (`~/Projects/GLTest`) was created with a single `main.swift`
that calls `EAGLContext(api: .openGLES2)` and `EAGLContext(api: .openGLES3)` and prints
the results. No MapLibre dependency — tests only the iOS Simulator OpenGL ES runtime.

Built with:
```
xcodebuild -scheme GLTest -sdk iphonesimulator \
  -destination "platform=iOS Simulator,name=iPhone SE (3rd generation)" build
```

Launched with `xcrun simctl launch --console-pty` on iPhone SE (3rd generation) simulator
running iOS 18.3.1 inside QEMU VM (macOS Sonoma, x86_64).

### Results

```
=== GPU CAPABILITIES ===
OpenGL ES 2.0: AVAILABLE
OpenGL ES 3.0: AVAILABLE
========================
```

### Interpretation

- **Metal:** NOT tested in this run (not included in GLTest); expected false in QEMU (confirmed previously)
- **OpenGL ES 2.0:** AVAILABLE — `EAGLContext(api: .openGLES2)` returns a non-nil context
- **OpenGL ES 3.0:** AVAILABLE — `EAGLContext(api: .openGLES3)` returns a non-nil context

### Go/No-Go Decision

**GO.** OpenGL ES 3.0 is available at runtime in the iOS Simulator running inside QEMU.

The iOS Simulator uses Apples software renderer on x86_64, which supports ES 3.0 regardless
---

## Runtime OpenGL ES Test — 2026-03-13

### Test Setup

A minimal Swift SPM project (~/Projects/GLTest) was created with a single main.swift
that calls EAGLContext(api: .openGLES2) and EAGLContext(api: .openGLES3) and prints
the results. No MapLibre dependency — tests only the iOS Simulator OpenGL ES runtime.

Built with xcodebuild -scheme GLTest -sdk iphonesimulator and launched via
xcrun simctl launch --console-pty on iPhone SE (3rd generation) running iOS 18.3.1
inside QEMU VM (macOS Sonoma, x86_64).

### Results

=== GPU CAPABILITIES ===
OpenGL ES 2.0: AVAILABLE
OpenGL ES 3.0: AVAILABLE
========================

### Interpretation

- Metal: NOT tested here; expected false in QEMU (confirmed previously)
- OpenGL ES 2.0: AVAILABLE — EAGLContext(api: .openGLES2) returns a non-nil context
- OpenGL ES 3.0: AVAILABLE — EAGLContext(api: .openGLES3) returns a non-nil context

### Go/No-Go Decision

GO. OpenGL ES 3.0 is available at runtime in the iOS Simulator running inside QEMU.

The iOS Simulator uses Apple software renderer on x86_64, which supports ES 3.0
regardless of whether the host GPU supports Metal. This confirms that MapLibre requirement
for kEAGLRenderingAPIOpenGLES3 (MLNMapView+OpenGL.mm:113) will be satisfied.

### Next Step

Proceed with Task 9: Install Bazelisk and attempt the Bazel OpenGL build of maplibre-native.

---

## Bazel Build — MapLibre Static XCFramework (OpenGL) — 2026-03-13

### Bazelisk Installation

Installed Bazelisk (Bazel launcher) as a standalone binary:
```bash
curl -L -o /tmp/bazel https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-darwin-amd64
chmod +x /tmp/bazel
sudo mv /tmp/bazel /usr/local/bin/bazel
```

Bazelisk downloaded Bazel 9.0.1 on first run. Verified: `bazel --version` -> `bazel 9.0.1`.

### Submodule Initialization

The shallow clone was missing vendor submodules. Fixed with:
```bash
cd ~/Projects/maplibre-native
git submodule update --init --recursive
```

This cloned all vendor dependencies (boost, freetype, harfbuzz, googletest, etc.).

### Build Attempt 1 — Failed

```bash
bazel build //platform/ios:MapLibre.static --//:renderer=drawable
```

Failed after ~3 minutes during analysis phase:
- `vendor/BUILD.bazel` glob for `cheap-ruler-cpp` headers failed (submodules not initialized)
- `vendor/maplibre-tile-spec/cpp` BUILD file not found

**Root cause:** Shallow clone did not include git submodules.

### Build Attempt 2 — SUCCESS

After initializing submodules, re-ran the same command:
```bash
bazel build //platform/ios:MapLibre.static --//:renderer=drawable
```

**Result: BUILD COMPLETED SUCCESSFULLY**

Key metrics:
- Total time: 3028 seconds (~50 minutes)
- Critical path: 190 seconds
- Total actions: 2,382 (226 internal, 1,882 darwin-sandbox, 274 local)
- All 12 CPU cores utilized (12 actions running concurrently)

### Output Artifact

**Location:** `bazel-bin/platform/ios/MapLibre.static.xcframework.zip` (85 MB)

Unzipped structure:
```
MapLibre.xcframework/
├── Info.plist
├── ios-arm64/
│   └── MapLibre.framework/
│       ├── Headers/ (87 headers)
│       ├── MapLibre (static library, arm64)
│       ├── Mapbox.bundle/
│       └── Modules/
└── ios-arm64_x86_64-simulator/
    └── MapLibre.framework/
        ├── Headers/ (87 headers + 2 umbrella)
        ├── MapLibre (fat static library, 409 MB, x86_64 + arm64)
        ├── Info.plist
        ├── Mapbox.bundle/
        └── Modules/
```

Total public headers: 174

Architecture verification:
```
$ lipo -info MapLibre.xcframework/ios-arm64_x86_64-simulator/MapLibre.framework/MapLibre
Architectures in the fat file: x86_64 arm64
```

### Renderer Confirmation

The `--//:renderer=drawable` flag selects the OpenGL (drawable) renderer. This is actually
the default value in `BUILD.bazel` (`build_setting_default = "drawable"`), but was specified
explicitly for clarity. The build included:
- `MLN_OPENGL_SOURCE` + `MLN_DRAWABLES_GL_SOURCE` (core OpenGL renderer)
- `MLN_IOS_PUBLIC_OBJCPP_OPENGL_SOURCE` = `MLNMapView+OpenGL.mm` (iOS OpenGL integration)

No Metal sources were compiled (`//:metal_renderer` was not selected).

### XCFramework Copied

The xcframework has been copied to `~/Projects/iOSMapsTest/MapLibre.xcframework/`
and the zip to `~/Projects/iOSMapsTest/MapLibre.static.xcframework.zip`.

### Next Step

Proceed with Task 10: Integrate the OpenGL xcframework into the iOSMapsTest Swift project.
