#pragma once

#include "renderer/IRendererBackend.h"

// Placeholder backend so Vulkan-specific plumbing can compile before real implementation exists.

class VulkanRendererStub final : public IRendererBackend
{
public:
    void initialize(const RendererInitInfo& info) override;
    void resize(int width, int height) override;
    void renderFrame(const RendererFrameInfo& info) override;
    double getSmoothedGpuFrameTimeMs() const override;
    void setResolutionScale(double scale) override;
};
