#pragma once

// Cross-platform presentation intent; platform layer may map unsupported modes.
enum class PresentationMode
{
    Windowed,
    Borderless,
    Exclusive
};

struct PresentationCapabilities
{
    bool supportsExclusiveFullscreen = false;
};

// Platform-specific presentation control (window/system integration).
class IPlatformPresentation
{
public:
    virtual ~IPlatformPresentation() = default;
    virtual PresentationCapabilities getPresentationCapabilities() const = 0;
    virtual void setPresentationMode(PresentationMode mode) = 0;
};
