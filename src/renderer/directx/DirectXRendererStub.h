#pragma once

#include "renderer/IRendererBackend.h"

// Placeholder backend so DirectX-specific plumbing can compile before real implementation exists.

class DirectXRendererStub final : public IRendererBackend
{
public:
    void initialize(const RendererInitInfo& info) override;
    void resize(int width, int height) override;
    void renderFrame(const RendererFrameInfo& info) override;
};
