#import "renderer/metal/Renderer.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <CoreVideo/CoreVideo.h>

#include <cmath>
#include <memory>

#include "renderer/IRendererBackend.h"
#include "engine/EngineCore.h"

// Metal-specific backend that owns the GPU objects and executes draw calls.
namespace
{
class MetalRendererBackend final : public IRendererBackend
{
public:
    void initialize(const RendererInitInfo& info) override
    {
        _view = (__bridge MTKView*)(info.nativeView);
        if (!_view)
        {
            return;
        }

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
        {
            return;
        }

        _timeSeconds += info.deltaTimeSeconds;

        MTLRenderPassDescriptor* rp = _view.currentRenderPassDescriptor;
        id<CAMetalDrawable> drawable = _view.currentDrawable;
        if (!rp || !drawable)
        {
            return;
        }

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

// Forward declaration for the CoreVideo callback that proxies ticks back to Renderer.
static CVReturn DisplayLinkCallback(CVDisplayLinkRef, const CVTimeStamp* now,
                                    const CVTimeStamp* outputTime, CVOptionFlags, CVOptionFlags*,
                                    void* displayLinkContext);

// Objective-C++ wrapper that owns the engine, listens to display-link ticks, and
// forwards delta times into the renderer backend.
@implementation Renderer
{
    std::unique_ptr<IRendererBackend> _backend;
    EngineCore _engine;
    __weak MTKView* _view;
    CVDisplayLinkRef _displayLink;
    double _pendingDeltaSeconds;
    double _fallbackDeltaSeconds;
    double _lastDisplayLinkTime;
}

- (instancetype)initWithMTKView:(MTKView*)view
{
    self = [super init];
    if (!self)
    {
        return nil;
    }

    _view = view;
    _fallbackDeltaSeconds = 1.0 / 60.0;
    _pendingDeltaSeconds = _fallbackDeltaSeconds;
    _lastDisplayLinkTime = 0.0;
    _displayLink = nullptr;

    _backend = std::make_unique<MetalRendererBackend>();

    RendererInitInfo initInfo{};
    initInfo.nativeView = (__bridge void*)view;
    _backend->initialize(initInfo);

    _engine.setRenderer(_backend.get());

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink) == kCVReturnSuccess)
    {
        CVDisplayLinkSetOutputCallback(_displayLink, &DisplayLinkCallback, (__bridge void*)self);
        CVDisplayLinkStart(_displayLink);
    }
#pragma clang diagnostic pop

    return self;
}

- (void)dealloc
{
    if (_displayLink)
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CVDisplayLinkStop(_displayLink);
        CVDisplayLinkRelease(_displayLink);
#pragma clang diagnostic pop
        _displayLink = nullptr;
    }
}

- (void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size
{
    (void)view;
    if (!_backend)
    {
        return;
    }

    _backend->resize(static_cast<int>(size.width), static_cast<int>(size.height));
}

- (void)drawInMTKView:(MTKView*)view
{
    (void)view;
    if (!_backend)
    {
        return;
    }

    double deltaSeconds =
        (_pendingDeltaSeconds > 0.0) ? _pendingDeltaSeconds : _fallbackDeltaSeconds;
    _pendingDeltaSeconds = 0.0;
    _engine.update(deltaSeconds);
}

- (void)requestDrawWithDelta:(double)deltaSeconds
{
    if (!_view)
    {
        return;
    }

    _pendingDeltaSeconds = deltaSeconds;
    [_view draw];
}

- (void)handleDisplayLinkTick:(const CVTimeStamp*)timestamp
{
    double currentSeconds = 0.0;
    if (timestamp->videoTimeScale != 0)
    {
        currentSeconds = static_cast<double>(timestamp->videoTime) /
                         static_cast<double>(timestamp->videoTimeScale);
    }

    double deltaSeconds = _fallbackDeltaSeconds;
    if (_lastDisplayLinkTime > 0.0 && currentSeconds > 0.0)
    {
        deltaSeconds = currentSeconds - _lastDisplayLinkTime;
    }
    _lastDisplayLinkTime = currentSeconds;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self requestDrawWithDelta:deltaSeconds];
    });
}

@end

static CVReturn DisplayLinkCallback(CVDisplayLinkRef, const CVTimeStamp* now,
                                    const CVTimeStamp* outputTime, CVOptionFlags, CVOptionFlags*,
                                    void* displayLinkContext)
{
    Renderer* renderer = (__bridge Renderer*)displayLinkContext;
    [renderer handleDisplayLinkTick:outputTime ? outputTime : now];
    return kCVReturnSuccess;
}
