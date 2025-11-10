#pragma once

class IRendererBackend;

// Platform-agnostic core loop that steps simulation and drives the renderer backend.
class EngineCore
{
public:
    void setRenderer(IRendererBackend* renderer);
    void update(double dt);

private:
    IRendererBackend* _renderer = nullptr;
};
