#import "Renderer.h"
#include "engine/EngineCore.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

@implementation Renderer
{
    id<MTLDevice> _device;
    id<MTLCommandQueue> _queue;
    EngineCore _engine;
}

- (instancetype)initWithMTKView:(MTKView*)view
{
    self = [super init];
    if (!self)
        return nil;

    _device = view.device ?: MTLCreateSystemDefaultDevice();
    view.device = _device;

    _queue = [_device newCommandQueue];

    view.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    view.depthStencilPixelFormat = MTLPixelFormatInvalid;
    view.preferredFramesPerSecond = 60;

    return self;
}

- (void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size
{
    // Handle resize later if needed
}

- (void)drawInMTKView:(MTKView*)view
{
    const static double dt = 1.0 / 30.0;
    static double t = 0.0;

    t += dt;
    _engine.update(dt);

    MTLRenderPassDescriptor* rp = view.currentRenderPassDescriptor;
    id<CAMetalDrawable> drawable = view.currentDrawable;
    if (!rp || !drawable)
        return;

    // Simple animated clear color to prove the loop is running
    double r = 0.5 + 0.5 * sin(t * 0.9);
    double g = 0.5 + 0.5 * sin(t * 1.3 + 2.0);
    double b = 0.5 + 0.5 * sin(t * 1.7 + 4.0);

    rp.colorAttachments[0].clearColor = MTLClearColorMake(r, g, b, 1.0);
    rp.colorAttachments[0].loadAction = MTLLoadActionClear;
    rp.colorAttachments[0].storeAction = MTLStoreActionStore;

    id<MTLCommandBuffer> cb = [_queue commandBuffer];
    id<MTLRenderCommandEncoder> enc = [cb renderCommandEncoderWithDescriptor:rp];

    [enc endEncoding];
    [cb presentDrawable:drawable];
    [cb commit];
}

@end