# Project Status & Next Steps

## 2026-01-21

### Session Notes
- **Git defaults**: set `pull.rebase=true` and `mergetool=opendiff` (Apple FileMerge).
- **Config cleanup**: cleaned repo-local `.git/config` entries and removed VS Code merge-base hints.
- **Origin HEAD**: clarified that `origin/HEAD` tracks the remote default branch, not the current branch upstream.
- **Remark**: consider switching the remote default branch to `development` on the server.

### Next Session
- **Backend selection plumbing**: sketch the platform-scoped registry/helper and decide how to expose valid backends on macOS.

## 2025-11-09

### Session Notes
- **AGENTS.md added**: added `AGENTS.md` so multiple Codex agents share the same repo playbook and coordination rules.
- **Annotations**: annotated the macOS bootstrap, engine loop, and renderer interface with inline comments to speed up future backend selection work.
- **Priority confirmed**: backend selection remains the top engineering priority; no code changes yet, but docs now outline expectations.

### Next Session
- **Backend selection plumbing**: sketch the platform-scoped registry/helper for platform-valid renderer options.
- **Bootstrap wiring**: route AppDelegate/Renderer through the helper instead of hard-coding Metal.
- **Documentation**: capture architectural decisions in `STATUS.md` as the plumbing lands.

## 2024-11-08

### Session Notes
- **Renderer abstraction landed**: EngineCore now talks through `IRendererBackend`, and the Metal backend is wrapped accordingly.
- **Source tree organized**: macOS bootstrap lives under `src/platform/macos`, Metal under `src/renderer/metal`, leaving room for other platforms/APIs.
- **Backend stubs compiling**: DirectX and Vulkan placeholders prove the interface compiles cross-backend.

### Next Session
- **Backend selection plumbing**: decide how to pick a backend (build flag, runtime setting, or platform auto-detect), then wire AppDelegate/EngineCore to honor that choice.
- **Engine loop enrichment**: replace the fixed 1/30s timestep with measured deltas and add hooks for simulation subsystems (physics, input, scene graph).
- **Renderer feature growth**: flesh out the Metal backend with a basic pipeline, then mirror the architecture for DirectX/Vulkan once designs are stable.
- **Longer-term ideas**: input + physics demo, telemetry overlay, multi-platform rollout, tooling, and asset pipeline.
