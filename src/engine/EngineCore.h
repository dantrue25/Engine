#pragma once

class IRendererBackend;

class EngineCore
{
public:
    void setRenderer(IRendererBackend* renderer);
    void update(double dt);

private:
    IRendererBackend* _renderer = nullptr;
};
