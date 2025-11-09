#pragma once

#include "renderer/IRendererBackend.h"

class VulkanRendererStub final : public IRendererBackend
{
public:
    void initialize(const RendererInitInfo& info) override;
    void resize(int width, int height) override;
    void renderFrame(const RendererFrameInfo& info) override;
};
