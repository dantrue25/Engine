#include "EngineCore.h"

#include "renderer/IRendererBackend.h"

void EngineCore::setRenderer(IRendererBackend* renderer)
{
    _renderer = renderer;
}

void EngineCore::update(double dt)
{
    if (!_renderer)
        return;

    RendererFrameInfo frameInfo{};
    frameInfo.deltaTimeSeconds = dt;
    _renderer->renderFrame(frameInfo);
}
