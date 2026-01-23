# 🚀 Engine

*A latency-first, adaptive real-time rendering engine focused on feel, predictability, and long-term scalability.*

---

## 🎯 Overview

**Engine** is an experimental real-time rendering engine built around a simple but demanding goal:

> **Make interactive systems feel good — immediately — on any machine.**

The engine prioritizes **input-to-photon latency**, explicit control over timing, and the ability to **adapt to the hardware it is running on**, rather than assuming a fixed resolution, frame rate, or performance tier.

Rather than targeting a specific class of machine, Engine is designed to **discover available headroom at runtime** and scale its workload accordingly — preserving responsiveness on constrained systems and automatically improving visual fidelity and frame rate on more capable ones.

---

## ⚡ Core Philosophy

### ⚡ Latency Is Paramount

Responsiveness comes first.

- Input-to-photon latency is prioritized over visual smoothness.
- Buffering to hide timing issues is avoided.
- When under load, the engine prefers **reducing work** over **adding latency**.

Default stance:
- minimal frames in flight
- late input sampling
- late rendering submission

Stalls are acceptable. Queued frames are not.

---

### 📈 Adaptive Performance & Graceful Scaling

Engine is built with the assumption that **hardware evolves faster than software**.

Instead of locking content to the performance characteristics of the machine it was authored on, the engine is designed to **adapt continuously to the headroom available on the system**.

This means:

- **Variable frame rate**  
  Rendering and presentation are not bound to a fixed cadence.

- **Variable resolution**  
  Render resolution is treated as a dynamic control variable, not a constant.

- **Headroom-driven scaling**  
  CPU and GPU timing are observed at runtime and used to adjust workload.

- **Longevity by design**  
  A game authored today should naturally render at higher resolution and frame rate on future hardware, without code or content changes.

When performance pressure arises, the engine reduces workload rather than buffering frames — preserving responsiveness even as visual fidelity adapts.

This adaptive behavior is **not a feature**; it is fundamental to the engine’s identity and inseparable from its latency-first design.

---

### ⏱️ Three Independent Clocks

The engine explicitly separates:

1. **Simulation time**  
   Deterministic, controlled, and decoupled from presentation.

2. **Render time**  
   Variable, driven by workload and available resources.

3. **Presentation time**  
   Controlled by the platform and display environment.

Predictability comes from **separation**, not forced alignment.

---

### 🧪 Observable, Not Magical

Instead of smoothing away variability, the engine exposes it.

Timing, pacing, and presentation behavior are intended to be **measurable and inspectable**, rather than hidden behind heuristics. Telemetry is favored over illusion.

---

### 🔄 VRR-Friendly (But Not Dependent)

Variable Refresh Rate (VRR) displays are embraced where available, as they:
- reduce worst-case latency
- eliminate fixed-refresh timing cliffs
- allow smooth degradation under load

However:
- VRR is never required
- non-VRR displays are fully supported
- engine behavior does not depend on display capabilities

Presentation timing is observed, not enforced.

---

## 🏗️ High-Level Architecture

The engine is structured into three clearly separated layers:

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

- **Engine Core**  
  Platform-agnostic logic governing simulation, timing, and frame orchestration.

- **Renderer Abstraction**  
  A narrow, explicit interface mapping engine intent to concrete graphics APIs.

- **Platform Layer**  
  OS-specific concerns such as windowing, input, and lifecycle management, isolated from core logic.

---

## 🎨 Renderer Backends

Renderer backends implement the same engine-facing abstraction and are described symmetrically.

### 🧱 Metal

**Status:** Implemented

- Maps engine-level rendering intent onto explicit GPU command submission.
- Presentation behavior follows the engine’s latency-first, adaptive philosophy within platform constraints.
- Resolution and drawable sizing are treated as dynamic.

---

### 🧩 DirectX 12

**Status:** Stub

- Intended to implement the same renderer abstraction using explicit command queues, resource binding, and pipeline state objects.
- Serves as a validation target for renderer interface design.

---

### 🔺 Vulkan

**Status:** Stub

- Intended to implement the renderer abstraction using Vulkan’s explicit synchronization and pipeline model.
- Acts as a cross-platform reference point for renderer architecture and shader portability.

---

## 🧩 Platform Layer

The platform layer is responsible for:
- window creation
- input collection
- lifecycle and startup coordination
- handing off surfaces to the renderer abstraction

Platform-specific behavior is explicitly isolated and does not leak into the engine core.

---

## 📍 Project Status & Direction

This README describes **architectural intent and philosophy**.

Concrete implementation details, progress, and next steps are tracked separately:

- `STATUS.md` — current reality and direction
- `AGENT.md` — strict rules and constraints for automated tooling

---

## ✨ Closing Thoughts

This project is an exploration of what happens when:

- latency is treated as a first-class design constraint
- performance scales with available headroom
- buffering is minimized instead of normalized
- hardware is allowed to improve the experience over time

It is not a framework, not a demo, and not a promise.

It is an engine shaped by **explicit tradeoffs**, built to feel good today — and better tomorrow.
