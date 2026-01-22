#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>
@class NSTextField;

/// Objective-C++ host that bridges MTKView callbacks into the C++ engine/renderer backend.
@interface Renderer : NSObject <MTKViewDelegate>
- (instancetype)initWithMTKView:(MTKView*)view;
- (void)setOverlayTextField:(NSTextField*)textField;
@end
