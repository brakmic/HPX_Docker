cmake_minimum_required(VERSION 3.15)
project(MyHPXApp)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Specify the path to HPX installation
set(HPX_ROOT "/usr/local/hpx")

# Find HPX
find_package(HPX REQUIRED)

add_executable(my_hpx_app src/main.cpp)

# Link HPX libraries
target_link_libraries(my_hpx_app PRIVATE HPX::hpx HPX::wrap_main)
