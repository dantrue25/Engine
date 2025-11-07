cmake_minimum_required(VERSION 3.22)
project(MetalEngine LANGUAGES C CXX OBJC OBJCXX)

# Create the .app bundle target (we'll add sources next)
add_executable(MetalEngine MACOSX_BUNDLE)
target_sources(MetalEngine PRIVATE 
  src/main.mm
  src/AppDelegate.mm
  src/Renderer.mm
)

# Basic bundle metadata
set_target_properties(MetalEngine PROPERTIES
  MACOSX_BUNDLE_BUNDLE_NAME "MetalEngine"
  MACOSX_BUNDLE_GUI_IDENTIFIER "com.example.metalengine"
)

# We'll add sources later via target_sources()
# We'll also link frameworks after the target exists:
target_link_libraries(MetalEngine
  "-framework Cocoa"
  "-framework Metal"
  "-framework MetalKit"
  "-framework QuartzCore"
)