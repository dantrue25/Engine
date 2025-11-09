#include "renderer/vulkan/VulkanRendererStub.h"

#include <cstdio>

void VulkanRendererStub::initialize(const RendererInitInfo& info)
{
    (void)info;
    std::puts("Vulkan backend not implemented yet.");
}

void VulkanRendererStub::resize(int width, int height)
{
    (void)width;
    (void)height;
}

void VulkanRendererStub::renderFrame(const RendererFrameInfo& info)
{
    (void)info;
}
