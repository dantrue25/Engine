#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
  @autoreleasepool {
    [NSApplication sharedApplication];
    AppDelegate *delegate = [AppDelegate new];
    [NSApp setDelegate:delegate];
    return NSApplicationMain(argc, argv);
  }
}