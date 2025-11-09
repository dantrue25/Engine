#pragma once

#include "renderer/IRendererBackend.h"

class DirectXRendererStub final : public IRendererBackend
{
public:
    void initialize(const RendererInitInfo& info) override;
    void resize(int width, int height) override;
    void renderFrame(const RendererFrameInfo& info) override;
};
