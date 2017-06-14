cmake_minimum_required(VERSION 3.7)
project(EPO4_pathfinder)

set(CMAKE_CXX_STANDARD 11)

set(MATLAB_ROOT "C:/Program Files/MATLAB/R2016b/extern/include")
include_directories(${MATLAB_ROOT})

#include_directories("C:/Program Files/MATLAB/R2016b/extern/include")

set(HEADER_FILES mex.h)
set(SOURCE_FILES main.cpp)


add_executable(EPO4_pathfinder ${SOURCE_FILES})