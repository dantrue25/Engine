# Engine

MetalEngine is a small macOS native rendering engine project that demonstrates a minimal application bundle using Metal, MetalKit and Cocoa. The codebase is intended as a lightweight starting point for exploring renderer design, platform integration (macOS), and an Objective‑C++ codepath for app bootstrapping.

This README documents the project purpose, repository layout, how to build and run locally, and a few developer tips (IntelliSense / editor configuration and recommended extensions).

## Purpose

- Provide a compact example of a macOS Metal application structured as a CMake project.
- Show how to integrate Objective‑C / Objective‑C++ (`.m` / `.mm`) sources into a cross-platform C++ project using CMake.
- Offer a simple renderer backend abstraction so different renderer implementations (e.g. Metal) can be swapped or extended.

## High-level structure

- `CMakeLists.txt` — top-level CMake configuration that creates the `MetalEngine` MacOSX bundle and links the required Apple frameworks.
- `src/` — main source tree:
	- `main.mm`, `AppDelegate.mm` / `.h` — macOS entry point and application lifecycle code (Objective‑C++ / Objective‑C).
	- `renderer/` — renderer interface and backends (the `IRendererBackend` interface and platform-specific renderer implementations).
	- `platform/macos/` — macOS specific platform glue and app bundle helpers.
	- `engine/` — core engine code (Engine initialization, main loop, etc.).
- `build/` — CMake-generated build directory (not committed). When configured with `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` this contains `compile_commands.json` used by language servers for accurate IntelliSense.

## Build (macOS)

Prerequisites:
- Xcode (Command Line Tools)
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

---

If you'd like, I can also add a short `CONTRIBUTING.md` and a `/.vscode/extensions.json` recommending the extensions above.