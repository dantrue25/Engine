#import "AppDelegate.h"
#import <MetalKit/MetalKit.h>
#import <AppKit/AppKit.h>
#import "renderer/metal/Renderer.h"

// Handles macOS application lifecycle: builds the window/MTKView pairing
// and wires the renderer delegate before showing the UI.
@implementation AppDelegate
{
    NSWindow* _window;
    MTKView* _mtkView;
    Renderer* _renderer;
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification
{
    NSRect frame = NSMakeRect(200, 200, 1280, 720);

    _window =
        [[NSWindow alloc] initWithContentRect:frame
                                    styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
                                               NSWindowStyleMaskResizable)
                                      backing:NSBackingStoreBuffered
                                        defer:NO];
    _window.title = @"MetalEngine (C++/Obj-C++)";

    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    _mtkView = [[MTKView alloc] initWithFrame:frame device:device];
    _mtkView.enableSetNeedsDisplay = NO;
    _mtkView.paused = YES;

    _renderer = [[Renderer alloc] initWithMTKView:_mtkView];
    _mtkView.delegate = _renderer;

    NSTextField* overlay = [NSTextField labelWithString:@""];
    overlay.font = [NSFont monospacedSystemFontOfSize:12.0 weight:NSFontWeightRegular];
    overlay.textColor = [NSColor colorWithCalibratedWhite:1.0 alpha:0.9];
    overlay.backgroundColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.4];
    overlay.drawsBackground = YES;
    overlay.bordered = NO;
    overlay.editable = NO;
    overlay.selectable = NO;
    overlay.lineBreakMode = NSLineBreakByTruncatingTail;

    CGFloat padding = 12.0;
    CGFloat overlayWidth = 280.0;
    CGFloat overlayHeight = 64.0;
    NSRect overlayFrame = NSMakeRect(padding,
                                     _mtkView.bounds.size.height - padding - overlayHeight,
                                     overlayWidth,
                                     overlayHeight);
    overlay.frame = overlayFrame;
    overlay.autoresizingMask = NSViewMinYMargin | NSViewMaxXMargin;
    [_mtkView addSubview:overlay];
    [_renderer setOverlayTextField:overlay];

    _window.contentView = _mtkView;
    [_window makeKeyAndOrderFront:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender
{
    return YES;
}

@end
