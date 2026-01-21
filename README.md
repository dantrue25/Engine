# Engine

MetalEngine is a small macOS native rendering engine project that demonstrates a minimal application bundle using Metal, MetalKit and Cocoa. The codebase is intended as a lightweight starting point for exploring renderer design, platform integration (macOS), and an Objective‑C++ codepath for app bootstrapping.

This README documents the project purpose, repository layout, how to build and run locally, and a few developer tips (IntelliSense / editor configuration and recommended extensions).

## Purpose

- Provide a compact example of a macOS Metal application structured as a CMake project.
- Show how to integrate Objective‑C / Objective‑C++ (`.m` / `.mm`) sources into a cross-platform C++ project using CMake.
- Offer a simple renderer backend abstraction so different renderer implementations (e.g. Metal) can be swapped or extended.

## Architecture

The project is split into three cooperating layers:

1. Platform bootstrap
   - macOS-specific Objective‑C++ entry points (`main.mm`, `AppDelegate.mm`) own the app lifecycle, window management, and native view objects (e.g., `MTKView`).
   - This layer is the only place that should talk to Cocoa/AppKit directly. Other platforms (Windows, Linux, iOS) would provide analogous bootstrap code under `src/platform/<platform>`.

2. Engine core
   - C++ code (`src/engine`) holds app-wide state, main-loop timing, and high-level orchestration.
   - It depends only on abstract interfaces (renderer, input, etc.) so it can be reused across platforms or graphics APIs without changes.

3. Renderer abstraction
   - A thin C++ interface (`IRendererBackend`, to be introduced) defines the operations the engine expects (initialize, resize, render frame).
   - Each graphics API implements that interface in its own module (e.g., Metal, DirectX 12, Vulkan). API-specific code stays isolated, but the engine calls them uniformly.

Data flow per frame:
platform bootstrap → engine tick (dt) → renderer backend → GPU commands. Resize or platform events bubble from bootstrap to engine, which forwards to the renderer.

This separation lets you ship one engine loop while swapping renderers per platform/configuration. Metal is the initial backend; DirectX/Vulkan backends will live alongside it once added.

## How the Code Runs (Story Mode)

1. **Bootstrap (Objective‑C++ entry)**
   - macOS launches `MetalEngine.app`, which calls `main` in `src/platform/macos/main.mm`.
   - `main` creates the `NSApplication`, instantiates `AppDelegate`, and hands control to AppKit via `NSApplicationMain`. From here AppKit drives the event loop.

2. **Window + view setup**
   - When the app finishes launching, `AppDelegate::applicationDidFinishLaunching` runs (`src/platform/macos/AppDelegate.mm`).
   - It creates an `NSWindow`, then builds an `MTKView` backed by the default `MTLDevice`.
   - The view’s delegate is set to an Objective‑C++ `Renderer` object (also defined under `src/renderer/metal`). AppKit will now call the delegate whenever the drawable size changes or a new frame should be rendered.

3. **Renderer host + engine handshake**
   - The `Renderer` Objective‑C++ class is a thin wrapper. In its initializer it:
     1. Creates a `MetalRendererBackend` (a C++ class that implements `IRendererBackend`).
     2. Passes the `MTKView` pointer down through `RendererInitInfo`, so the backend can configure Metal objects.
     3. Creates an `EngineCore`, calls `setRenderer` with the backend instance, and stores a fixed timestep (currently 1/30 s).
   - At this point, the C++ world and the Objective‑C world are linked through the backend interface.

4. **Per-frame flow**
   - AppKit ticks at the MTKView’s preferred frame rate (60 FPS). For each frame:
     - `Renderer::drawInMTKView` runs. It simply forwards the fixed delta time to `EngineCore::update`.
     - `EngineCore` builds a `RendererFrameInfo` with that delta and calls `_renderer->renderFrame(frameInfo)`.
     - The active backend is still Metal, so control lands in `MetalRendererBackend::renderFrame`.

5. **Metal backend internals**
   - The backend owns the Metal device, command queue, and keeps a monotonically increasing time accumulator.
   - During `renderFrame` it asks the MTKView for a render pass descriptor and drawable. If either is missing, it skips the frame gracefully.
   - Otherwise it computes an animated RGB clear color with sine waves (proving the GPU is being driven), writes that into the color attachment, encodes an empty pass, presents the drawable, and commits the command buffer.
   - Resize callbacks (`mtkView:drawableSizeWillChange:`) forward dimension changes into `IRendererBackend::resize`, which currently ignores them but establishes the hook for real handling later.

6. **Extensibility hooks**
   - The DirectX and Vulkan directories contain stub implementations of `IRendererBackend`. They compile and link today, but only log that they’re unimplemented. Swapping to them will eventually happen via platform/build selection logic.
   - Because the engine speaks only through `IRendererBackend`, you can lift `src/engine` and the relevant renderer backend to other platforms without touching the app bootstrap.

In short: macOS/AppKit owns the event loop, the Objective‑C layer owns platform UI, the C++ engine owns the simulation tick, and renderer backends translate that tick into GPU work. The code is structured so you can trace the call stack in order: `main` → `AppDelegate` → `Renderer (Obj‑C++)` → `EngineCore (C++)` → `MetalRendererBackend (C++/Metal)`.

## High-level structure

- `CMakeLists.txt` — top-level CMake configuration that creates the `MetalEngine` MacOSX bundle and links the required Apple frameworks.
- `src/` — main source tree:
	- `main.mm`, `AppDelegate.mm` / `.h` — macOS entry point and application lifecycle code (Objective‑C++ / Objective‑C).
	- `renderer/` — renderer interface and backends (the `IRendererBackend` interface and platform-specific renderer implementations).
	- `platform/macos/` — macOS specific platform glue and app bundle helpers.
	- `engine/` — core engine code (Engine initialization, main loop, etc.).
- `build/` — CMake-generated build directory (not committed). When configured with `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` this contains `compile_commands.json` used by language servers for accurate IntelliSense.

## Build (macOS)

Prerequisites (macOS Metal app bundle):
- Xcode (Command Line Tools) — required for the macOS Metal backend (app bundle, windowing, Metal compilation).
- CMake (>= 3.22)

From the repository root:

```bash
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build --config Debug
```

This will produce a macOS bundle under `build/MetalEngine.app` when the build succeeds.

To run the app:

```bash
open build/MetalEngine.app
```

## Core engine / renderer requirements

The engine core and renderer abstraction are CMake + C++ and are intended to be buildable with a standard C++ toolchain on non-macOS platforms. They do not inherently require Xcode; Xcode is only needed for the macOS platform bootstrap and Metal backend.

## Development / Editor tips

- Recommended VS Code extensions:
	- CMake Tools (`ms-vscode.cmake-tools`) — configure/build from within VS Code.
	- clangd (clangd extension) — better Objective‑C/Objective‑C++ language features; point it at `build/compile_commands.json`.
	- C/C++ (`ms-vscode.cpptools`) — optional; works as an alternative language provider but may be less accurate for Obj‑C++ on macOS.

- IntelliSense notes:
	- Regenerate compile commands whenever CMake flags change:
		`cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON`
	- If using clangd, set the clangd path in workspace settings and use `--compile-commands-dir=build` so clangd reads the compilation database.
	- If using cpptools, point `c_cpp_properties.json` at `${workspaceFolder}/build/compile_commands.json` and set `compilerPath` to `/usr/bin/clang++` on macOS.

## Version control and workflow

- The project uses a typical feature-branch workflow. Commit frequently and push to your remote to back up work.
- Before destructive operations, create a backup branch:

```bash
git branch backup/local-before-reset
```

## Contributing

- Keep platform-specific code (macOS) inside `src/platform/macos` and keep renderer interface code platform-agnostic under `src/renderer`.
- Add unit tests or small example scenes under `tests/` if you expand the project.

## License

Add a license file (e.g. `LICENSE`) and reference it here.
