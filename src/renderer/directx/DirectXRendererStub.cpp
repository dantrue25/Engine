#include "renderer/directx/DirectXRendererStub.h"

#include <cstdio>

void DirectXRendererStub::initialize(const RendererInitInfo& info)
{
    (void)info;
    std::puts("DirectX backend not implemented yet.");
}

void DirectXRendererStub::resize(int width, int height)
{
    (void)width;
    (void)height;
}

void DirectXRendererStub::renderFrame(const RendererFrameInfo& info)
{
    (void)info;
}

double DirectXRendererStub::getSmoothedGpuFrameTimeMs() const
{
    return 0.0;
}

void DirectXRendererStub::setResolutionScale(double scale)
{
    (void)scale;
}
