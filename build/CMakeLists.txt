message("LETS GO!")

cmake_minimum_required(VERSION 3.1...3.15)

if(${CMAKE_VERSION} VERSION_LESS 3.12)
  cmake_policy(VERSION ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION})
endif()

# set the project name
project(TouchThaBomb  VERSION 0.1
                      DESCRIPTION "Defuse bomb game with hand tracking"
                      LANGUAGES CXX)


# https://cmake.org/cmake/help/latest/command/find_package.html#search-procedure 
find_package(OpenCV 4.3 EXACT REQUIRED PATHS /OpenCV/opencv-4.3.0-vc16/)
include_directories(AFTER "${OpenCV_INCLUDE_DIRS}" "include")
link_libraries(${OpenCV_LIBS})

link_libraries("../godot-cpp/bin/libgodot-cpp.windows.debug.64")

# create the .dll
#file(GLOB source_list "src/*.h" "src/*.cpp")
add_library(libcursor SHARED "../src/cursor.cpp" "../src/gdlibrary.cpp")

include_directories(
  "../godot-cpp/godot_headers/"
  "../godot-cpp/include/"
  "../godot-cpp/include/core/"
  "../godot-cpp/include/gen/"
  "../godot-cpp/bin/"
)
