#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>

@interface Renderer : NSObject <MTKViewDelegate>
- (instancetype)initWithMTKView:(MTKView *)view;
@end