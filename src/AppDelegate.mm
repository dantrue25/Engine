#import "AppDelegate.h"
#import <MetalKit/MetalKit.h>
#import "Renderer.h"

@implementation AppDelegate {
    NSWindow *_window;
    MTKView *_mtkView;
    Renderer *_renderer;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    NSRect frame = NSMakeRect(200, 200, 1280, 720);

    _window = [[NSWindow alloc] initWithContentRect:frame
                                          styleMask:(NSWindowStyleMaskTitled |
                                                     NSWindowStyleMaskClosable |
                                                     NSWindowStyleMaskResizable)
                                            backing:NSBackingStoreBuffered
                                              defer:NO];
    _window.title = @"MetalEngine (C++/Obj-C++)";

    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    _mtkView = [[MTKView alloc] initWithFrame:frame device:device];

    _renderer = [[Renderer alloc] initWithMTKView:_mtkView];
    _mtkView.delegate = _renderer;

    _window.contentView = _mtkView;
    [_window makeKeyAndOrderFront:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end