# Engine

A latency-first real-time rendering engine with adaptive performance behavior.

## Overview

Engine is an experimental renderer focused on input-to-photon latency, explicit timing control, and adaptive workload scaling based on runtime headroom. It does not assume a fixed resolution, frame rate, or performance tier. The goal is predictable responsiveness across a wide range of hardware.

## Core Philosophy

### Latency First

- Prefer reduced work over added latency when under load.
- Avoid buffering to hide timing issues.
- Use minimal frames in flight.
- Sample input late and submit rendering late.

### Adaptive Performance

- Variable frame rate.
- Variable render resolution.
- CPU/GPU timing telemetry guides scaling.
- Content authored once should scale up on future hardware without changes.

### Independent Clocks

The engine separates:

1. Simulation time (deterministic and controlled).
2. Render time (variable based on workload).
3. Presentation time (platform/display controlled).

### Observable Behavior

Timing and pacing are intended to be measurable and inspectable. The engine favors telemetry over hidden heuristics.

### VRR Compatibility

- VRR reduces worst-case latency and timing cliffs where available.
- VRR is not required; non-VRR displays are supported.
- Presentation timing is observed, not enforced.

## Architecture

Three layers:

    +-----------------------------+
    |        Engine Core          |
    |  (simulation, timing, API)  |
    +-----------------------------+
    |     Renderer Abstraction    |
    |  (backend-neutral interface)|
    +-----------------------------+
    |        Platform Layer       |
    | (windowing, input, startup) |
    +-----------------------------+

- Engine Core: platform-agnostic logic for simulation, timing, and frame orchestration.
- Renderer Abstraction: narrow interface mapping engine intent to graphics APIs.
- Platform Layer: OS-specific windowing, input, and lifecycle concerns.

## Design Decisions

- Presentation intent is abstracted via `src/platform/PlatformPresentation.h` so platform policy (windowed/borderless/exclusive) is expressed in a backend-neutral form.
- macOS presentation is composited (CAMetalLayer -> compositor), so presentation timing is treated as observed behavior rather than something the engine controls (`src/platform/macos/MacOSPresentation.mm`).
- Timing and pacing are designed to be measurable; telemetry is a first-class output of the runtime rather than a hidden implementation detail.
- Presentation intent may not match presentation reality; the engine records intent and treats the display system as authoritative (`src/platform/macos/MacOSPresentation.mm`).
- Exclusive fullscreen is treated as intent only; the engine does not assume exclusive scanout control (`src/platform/macos/MacOSPresentation.mm`).
- Shader/pipeline compilation must not block gameplay; compilation should be prebuilt or async (`src/renderer/IRendererBackend.h`).
- Input sampling and render submission are intended to be as late as possible to minimize end-to-end latency (`src/renderer/metal/Renderer.mm`).

## Key Code Paths

### Engine core

- `src/engine/EngineCore.h` defines the platform-agnostic loop entry points: `setRenderer` and `update`.
- `EngineCore::update` (`src/engine/EngineCore.cpp`) is the single entry point that turns a delta time into a renderer call.

### Renderer contract

- `src/renderer/IRendererBackend.h` defines the backend API used by the engine: initialize, resize, render, GPU timing query, and resolution scale control.
- `RendererInitInfo` carries the native view pointer (`MTKView*` on macOS) so the backend can configure API-specific state without polluting the engine.

### macOS bootstrap

- `src/platform/macos/main.mm` creates the shared `NSApplication`, installs `AppDelegate`, and hands control to AppKit.
- `src/platform/macos/AppDelegate.mm` builds the `NSWindow` and `MTKView`, wires the `Renderer` delegate, and installs the on-screen text overlay.

### Metal renderer host and backend

- Metal-specific callouts are listed under the macOS (Metal) platform section.

### Presentation intent adapter

- `src/platform/PlatformPresentation.h` defines `PresentationMode` and `IPlatformPresentation` to keep presentation policy cross-platform.
- `MacOSPresentation::setPresentationMode` (`src/platform/macos/MacOSPresentation.mm`) maps unsupported exclusive fullscreen to borderless to preserve intent without claiming OS control that macOS does not provide.

## Platforms

### macOS (Metal)

Backend

- Maps engine intent to Metal command submission.
- Presentation behavior follows latency-first policy within platform constraints.
- Resolution/drawable sizing are dynamic.

Points of interest

- `src/renderer/metal/Renderer.mm` owns `EngineCore`, a `MetalRendererBackend`, and a CoreVideo display link.
- `Renderer::handleDisplayLinkTick` computes a display-link delta, dispatches to the main queue, and requests a draw on the `MTKView`.
- `Renderer::requestDrawWithDelta` sets `_pendingDeltaSeconds` and triggers `-[MTKView draw]` for manual frame submission.
- `Renderer::drawInMTKView` reads `_pendingDeltaSeconds`, calls `EngineCore::update`, and updates the HUD text.
- `_pendingDeltaSeconds` and `_fallbackDeltaSeconds` control the timing fallback when display-link data is missing.
- `MetalRendererBackend::renderFrame` is the current GPU work path: drawable acquire, clear pass encode, present, commit.
- `MetalRendererBackend::getSmoothedGpuFrameTimeMs` returns the smoothed GPU timing used by the HUD.
- `_smoothedGpuFrameTimeMs` and `_gpuFrameSmoothing` control smoothing in the command buffer completion handler.
- `MetalRendererBackend::setResolutionScale` clamps the scale and updates `MTKView.drawableSize`, providing a hook for dynamic resolution.

Execution flow

1. Bootstrap (Objective-C++)
   - macOS launches `MetalEngine.app`, which calls `main` in `src/platform/macos/main.mm`.
   - `main` creates the `NSApplication`, instantiates `AppDelegate`, and hands control to AppKit via `NSApplicationMain`.

2. Window and view setup
   - `AppDelegate::applicationDidFinishLaunching` runs in `src/platform/macos/AppDelegate.mm`.
   - It creates an `NSWindow` and an `MTKView` backed by the default `MTLDevice`.
   - The view's delegate is set to the Objective-C++ `Renderer` in `src/renderer/metal`.

3. Renderer host and engine handshake
   - `Renderer` constructs a `MetalRendererBackend` and passes `MTKView` via `RendererInitInfo`.
   - `Renderer` constructs `EngineCore` and calls `setRenderer` with the backend instance.

4. Per-frame flow
   - AppKit triggers `Renderer::drawInMTKView`.
   - `Renderer` forwards delta time to `EngineCore::update`.
   - `EngineCore` builds `RendererFrameInfo` and calls `IRendererBackend::renderFrame`.

5. Metal backend work
   - `MetalRendererBackend::renderFrame` requests a render pass descriptor and drawable from `MTKView`.
   - If either is missing, the frame is skipped.
   - Otherwise it encodes a clear pass, presents the drawable, and commits the command buffer.

### Windows (DirectX 12, planned)

Backend

- Intended to mirror the renderer abstraction using explicit queues and pipeline state objects.
- Serves as a validation target for the interface design.
- The backend in `src/renderer/directx` is a stub and logs "not implemented."

Points of interest

- Placeholder until the DirectX backend is implemented.

Execution flow

- Platform bootstrap will live under `src/platform/windows`.
- Flow will mirror macOS: platform bootstrap -> engine tick -> backend render.

### Windows/Linux (Vulkan, planned)

Backend

- Intended to mirror the renderer abstraction using explicit synchronization and pipelines.
- Acts as a cross-platform reference for renderer architecture and shader portability.
- The backend in `src/renderer/vulkan` is a stub and logs "not implemented."

Points of interest

- Placeholder until the Vulkan backend is implemented.

Execution flow

- Platform bootstrap will be per-target under `src/platform/<platform>`.
- Flow will mirror the same engine-facing interface.

## Platform Layer

Responsibilities:

- Window creation
- Input collection
- Lifecycle and startup coordination
- Surface handoff to the renderer abstraction

Platform-specific behavior is isolated from the engine core.

## Project Status

This file describes architecture and intent. Current progress and next steps:

- `STATUS.md`
- `AGENTS.md`
