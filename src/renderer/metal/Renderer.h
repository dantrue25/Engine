#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>

/// Objective-C++ host that bridges MTKView callbacks into the C++ engine/renderer backend.
@interface Renderer : NSObject <MTKViewDelegate>
- (instancetype)initWithMTKView:(MTKView*)view;
@end
