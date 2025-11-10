# Project Status & Next Steps

## 2025-11-09 Snapshot

### Highlights
- Added `AGENTS.md` so multiple Codex agents share the same repo playbook and coordination rules.
- Annotated the macOS bootstrap, engine loop, and renderer interface with inline comments to speed up future backend selection work.
- Confirmed backend selection remains the top engineering priority; no code changes yet, but docs now outline expectations.

### Immediate Next Steps
1. Sketch a backend registry/helper that exposes only platform-valid renderer options.
2. Thread that helper through the macOS bootstrap so AppDelegate/Renderer instantiate the selected backend instead of hard-coding Metal.
3. Document any architectural decisions that emerge during the plumbing in `STATUS.md` to keep future agents aligned.

## 2024-11-08 Snapshot

### Current Focus
- **Renderer abstraction landed**: EngineCore now talks through `IRendererBackend`, and the Metal backend is wrapped accordingly.
- **Source tree organized**: macOS bootstrap lives under `src/platform/macos`, Metal under `src/renderer/metal`, leaving room for other platforms/APIs.
- **Backend stubs compiling**: DirectX and Vulkan placeholders prove the interface compiles cross-backend.

### Active Goals
1. **Backend selection plumbing**  
   - Decide how to pick a backend (build flag, runtime setting, or platform auto-detect).  
   - Wire AppDelegate/EngineCore to honor that choice.
2. **Engine loop enrichment**  
   - Replace the fixed 1/30s timestep with measured deltas.  
   - Add hooks for simulation subsystems (physics, input, scene graph).
3. **Renderer feature growth**  
   - Flesh out the Metal backend with a basic pipeline (vertex/index buffers, simple material).  
   - Mirror the architecture for DirectX/Vulkan once designs are stable.

### Near-Term Experiments
- **Input abstraction**: define a cross-platform input interface so macOS keyboard/mouse events—and future touch/accelerometer data—reach the engine consistently.
- **Physics playground**: integrate a lightweight physics step (e.g., sphere bouncing in a box) to validate the game-loop timing.
- **Telemetry overlay**: render basic HUD text (FPS, backend, debug toggles) to ensure UI+render code coexist.

### Longer-Term Directions
- **Multi-platform rollout**  
  - macOS Metal (current)  
  - Windows DirectX 12 backend (focus on swap-chain plumbing, descriptor heaps)  
  - Cross-platform Vulkan backend with shared SPIR-V shaders.
- **iPad sensor bridge**  
  - Build a small companion app that streams accelerometer/gyro data over the network.  
  - Add an input device layer in the engine to consume those readings and drive a physics demo (e.g., tilt-to-roll ball scene).
- **Tooling and automation**  
  - Unit/integration tests for renderer interface contracts.  
  - CI job that at least configures/builds macOS target and runs headless validation (future: screenshot comparisons).

### Backlog / Ideas Parking Lot
- Hot-reloadable shaders/resource pipelines.
- Simple ECS or component graph for game objects.
- Asset import pipeline (glTF meshes, texture baking).
- Remote debugging panel (web UI) to tweak engine parameters live.
