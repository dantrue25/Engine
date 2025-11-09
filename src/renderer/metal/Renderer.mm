#import "renderer/metal/Renderer.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

#include <cmath>
#include <memory>

#include "renderer/IRendererBackend.h"
#include "engine/EngineCore.h"

namespace
{
class MetalRendererBackend final : public IRendererBackend
{
public:
    void initialize(const RendererInitInfo& info) override
    {
        _view = static_cast<MTKView*>(info.nativeView);
        if (!_view)
            return;

        _device = _view.device ?: MTLCreateSystemDefaultDevice();
        _view.device = _device;
        _queue = [_device newCommandQueue];

        _view.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
        _view.depthStencilPixelFormat = MTLPixelFormatInvalid;
        _view.preferredFramesPerSecond = 60;
    }

    void resize(int width, int height) override
    {
        (void)width;
        (void)height;
        // Resize handling will be implemented once the engine needs it.
    }

    void renderFrame(const RendererFrameInfo& info) override
    {
        if (!_view)
            return;

        _timeSeconds += info.deltaTimeSeconds;

        MTLRenderPassDescriptor* rp = _view.currentRenderPassDescriptor;
        id<CAMetalDrawable> drawable = _view.currentDrawable;
        if (!rp || !drawable)
            return;

        double r = 0.5 + 0.5 * sin(_timeSeconds * 0.9);
        double g = 0.5 + 0.5 * sin(_timeSeconds * 1.3 + 2.0);
        double b = 0.5 + 0.5 * sin(_timeSeconds * 1.7 + 4.0);

        rp.colorAttachments[0].clearColor = MTLClearColorMake(r, g, b, 1.0);
        rp.colorAttachments[0].loadAction = MTLLoadActionClear;
        rp.colorAttachments[0].storeAction = MTLStoreActionStore;

        id<MTLCommandBuffer> cb = [_queue commandBuffer];
        id<MTLRenderCommandEncoder> enc = [cb renderCommandEncoderWithDescriptor:rp];

        [enc endEncoding];
        [cb presentDrawable:drawable];
        [cb commit];
    }

private:
    MTKView* _view = nil;
    id<MTLDevice> _device = nil;
    id<MTLCommandQueue> _queue = nil;
    double _timeSeconds = 0.0;
};
} // namespace

@implementation Renderer
{
    std::unique_ptr<IRendererBackend> _backend;
    EngineCore _engine;
    double _fixedDeltaSeconds;
}

- (instancetype)initWithMTKView:(MTKView*)view
{
    self = [super init];
    if (!self)
        return nil;

    _backend = std::make_unique<MetalRendererBackend>();

    RendererInitInfo initInfo{};
    initInfo.nativeView = view;
    _backend->initialize(initInfo);

    _fixedDeltaSeconds = 1.0 / 30.0;
    _engine.setRenderer(_backend.get());

    return self;
}

- (void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size
{
    (void)view;
    if (!_backend)
        return;

    _backend->resize(static_cast<int>(size.width), static_cast<int>(size.height));
}

- (void)drawInMTKView:(MTKView*)view
{
    (void)view;
    if (!_backend)
        return;

    _engine.update(_fixedDeltaSeconds);
}

@end
