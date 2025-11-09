#pragma once

struct RendererInitInfo
{
    void* nativeView = nullptr; // Platform-specific view/window handle (e.g., MTKView*)
};

struct RendererFrameInfo
{
    double deltaTimeSeconds = 0.0;
};

class IRendererBackend
{
public:
    virtual ~IRendererBackend() = default;
    virtual void initialize(const RendererInitInfo& info) = 0;
    virtual void resize(int width, int height) = 0;
    virtual void renderFrame(const RendererFrameInfo& info) = 0;
};
