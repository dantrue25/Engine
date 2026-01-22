#pragma once

#include "platform/PlatformPresentation.h"

// macOS presentation adapter; uses native window behavior and maps unsupported modes.
class MacOSPresentation final : public IPlatformPresentation
{
public:
    explicit MacOSPresentation(void* nativeWindow);

    PresentationCapabilities getPresentationCapabilities() const override;
    void setPresentationMode(PresentationMode mode) override;

private:
    void* _nativeWindow = nullptr;
    PresentationMode _activeMode = PresentationMode::Windowed;
};
