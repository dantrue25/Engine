#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

// Entry point for the macOS bundle. Creates the shared NSApplication,
// installs AppDelegate, and hands control to AppKit's event loop.

int main(int argc, const char* argv[])
{
    @autoreleasepool
    {
        [NSApplication sharedApplication];
        AppDelegate* delegate = [AppDelegate new];
        [NSApp setDelegate:delegate];
        return NSApplicationMain(argc, argv);
    }
}
