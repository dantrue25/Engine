#pragma once

// Describes the data required to bootstrap a renderer backend and drive frames uniformly across APIs.
struct RendererInitInfo
{
    void* nativeView = nullptr; // Platform-specific view/window handle (e.g., MTKView*)
};

// Per-frame data: currently just delta time, but extendable with camera/scene info later.
struct RendererFrameInfo
{
    double deltaTimeSeconds = 0.0;
};

// Abstract renderer contract implemented by Metal/DirectX/Vulkan backends.
class IRendererBackend
{
public:
    virtual ~IRendererBackend() = default;
    virtual void initialize(const RendererInitInfo& info) = 0;
    virtual void resize(int width, int height) = 0;
    virtual void renderFrame(const RendererFrameInfo& info) = 0;
};
