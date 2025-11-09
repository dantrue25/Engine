cmake_minimum_required(VERSION 3.22)

project(MetalEngine LANGUAGES C CXX OBJC OBJCXX)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_executable(MetalEngine MACOSX_BUNDLE
    src/platform/macos/main.mm
    src/platform/macos/AppDelegate.mm
    src/renderer/metal/Renderer.mm
    src/renderer/directx/DirectXRendererStub.cpp
    src/renderer/vulkan/VulkanRendererStub.cpp
    src/engine/EngineCore.cpp
)

set_target_properties(MetalEngine PROPERTIES
    MACOSX_BUNDLE_BUNDLE_NAME "MetalEngine"
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.example.metalengine"
)

target_link_libraries(MetalEngine
    "-framework Cocoa"
    "-framework Metal"
    "-framework MetalKit"
    "-framework QuartzCore"
)

target_include_directories(MetalEngine PRIVATE src)
