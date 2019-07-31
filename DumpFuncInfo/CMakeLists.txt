cmake_minimum_required(VERSION 3.5)
set (CMAKE_CXX_STANDARD 11)

find_package(LLVM REQUIRED CONFIG HINTS ${LLVM_BUILD_DIR})

add_definitions(${LLVM_DEFINITIONS})
include_directories(${LLVM_INCLUDE_DIRS})

SET(CMAKE_CXX_FLAGS "-Wall -fno-rtti")
add_subdirectory(FuncInfoPass)
