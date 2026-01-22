#import <AppKit/AppKit.h>

#include "platform/macos/MacOSPresentation.h"

MacOSPresentation::MacOSPresentation(void* nativeWindow)
    : _nativeWindow(nativeWindow)
{
}

PresentationCapabilities MacOSPresentation::getPresentationCapabilities() const
{
    PresentationCapabilities caps{};
    caps.supportsExclusiveFullscreen = false;
    return caps;
}

void MacOSPresentation::setPresentationMode(PresentationMode mode)
{
    if (!_nativeWindow)
    {
        return;
    }

    // macOS does not expose true exclusive fullscreen; map to borderless intent.
    PresentationMode resolved =
        (mode == PresentationMode::Exclusive) ? PresentationMode::Borderless : mode;
    _activeMode = resolved;

    // TODO: Apply resolved mode to the NSWindow once window management is centralized.
    (void)resolved;
}
