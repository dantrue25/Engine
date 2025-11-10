# Repository Guidelines

## Project Structure & Module Organization
- `src/platform/macos/` — App bootstrap (`main.mm`, `AppDelegate.mm`) and platform glue.
- `src/renderer/metal/` — Objective‑C++ host plus Metal backend implementation.
- `src/renderer/{directx,vulkan}/` — Stub backends that compile but currently log “not implemented”.
- `src/engine/` — Cross-platform engine core; owns the render loop and future simulation code.
- `STATUS.md` tracks dated roadmap snapshots; `README.md` explains architecture and runtime story.

## Build, Test, and Development Commands
- `cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON` — Configure the macOS bundle and emit `compile_commands.json`.
- `cmake --build build --config Debug --clean-first` — Rebuild the app bundle using the generated project files.
- `open build/MetalEngine.app` — Launch the GUI locally (not supported inside the Codex sandbox).

## Coding Style & Naming Conventions
- C++/ObjC++ formatting is enforced via `.clang-format` (LLVM base style, Allman braces, no short `if` bodies). Run `clang-format -i <file>` before committing.
- Stick to descriptive PascalCase class names (`EngineCore`, `MetalRendererBackend`) and lowerCamelCase method names.
- Keep Objective-C literals and messaging consistent with existing style (`[object method]` on separate lines when multi-parameter).

## Testing Guidelines
- No automated test harness yet. When adding tests, place them under `tests/` (create if missing) and document the command needed to run them.
- Favor deterministic, headless validation (e.g., unit tests for math/engine subsystems) since the GUI can’t run in CI.

## Commit & Pull Request Guidelines
- Follow the existing pattern: short imperative subject summarizing the change, followed by bullet points detailing key updates (see commit `d7d9fd1` for reference).
- Every PR should describe the change, note manual test results (e.g., “Ran `cmake --build …`”), and include screenshots if UI behavior changed.
- Link relevant issues in the PR description and call out follow-up tasks in `STATUS.md` when appropriate.

## Collaboration Preferences & Context
- Work **step-by-step**: propose a single action, wait for confirmation, and keep the user involved in decisions. Explicitly explain why each step matters.
- Favor **low-level control** and educational detail. The user enjoys understanding how rendering, timing loops, and GPU plumbing work; explain architecture choices and provide reasoning when suggesting alternatives.
- Keep terminal outputs concise and avoid cluttering the user’s screen. They prefer summaries over raw command dumps and like code snippets to be clearly indented in explanations.
- Multi-backend rendering (Metal now, DirectX/Vulkan later) is a core learning goal. Highlight how changes align with that roadmap and update `STATUS.md` when plans shift.

## Session Handoff — 2025-11-09
- Docs refreshed today: `README.md` now mentions `AGENTS.md`; `STATUS.md` snapshot updated with new highlights/next steps.
- Backend selection plumbing is the next coding task. user wants guidance before any edits; start by proposing a backend registry/helper scoped per platform.
- Metal is still the only functional backend; DirectX/Vulkan remain stubs. goal is to create hooks without exposing invalid options on macOS.
- No outstanding code changes; working tree clean after commit `069c64f`. When resuming, confirm with the user before touching files.
