# TODO: supply toolchain file instead(https://review.mlplatform.org/plugins/gitiles/ml/ethos-u/ethos-u-core-platform/+/refs/tags/20.11/cmake/toolchain/arm-none-eabi-gcc.cmake)
set(TARGET_CPU "cortex-m55")
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_C_COMPILER "arm-none-eabi-gcc")
set(CMAKE_CXX_COMPILER "arm-none-eabi-g++")

# Convert TARGET_CPU=Cortex-M33+nofp+nodsp into
#   - CMAKE_SYSTEM_PROCESSOR=cortex-m33
#   - TARGET_CPU_FEATURES=no-fp;no-dsp
string(REPLACE "+" ";" TARGET_CPU_FEATURES ${TARGET_CPU})
list(POP_FRONT TARGET_CPU_FEATURES CMAKE_SYSTEM_PROCESSOR)
string(TOLOWER ${CMAKE_SYSTEM_PROCESSOR} CMAKE_SYSTEM_PROCESSOR)
# set(CMAKE_EXECUTABLE_SUFFIX ".elf")
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
# Select C/C++ version
set(CMAKE_C_STANDARD 99)
set(CMAKE_CXX_STANDARD 14)
# Compile options
add_compile_options(
    -mcpu=${TARGET_CPU}
    -mthumb
    "$<$<COMPILE_LANGUAGE:CXX>:-fno-unwind-tables;-fno-rtti;-fno-exceptions>")
# Link options
add_link_options(
    -mcpu=${TARGET_CPU}
    -mthumb
    --specs=nosys.specs)
# Set floating point unit
if("${TARGET_CPU}" MATCHES "\\+fp")
    set(FLOAT hard)
elseif("${TARGET_CPU}" MATCHES "\\+nofp")
    set(FLOAT soft)
elseif("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "cortex-m33" OR
       "${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "cortex-m55")
    set(FLOAT hard)
else()
    set(FLOAT soft)
endif()
if (FLOAT)
    add_compile_options(-mfloat-abi=${FLOAT})
    add_link_options(-mfloat-abi=${FLOAT})
endif()
# Compilation warnings
add_compile_options(
    -Wall
    -Wextra
    -Wsign-compare
    -Wunused
    -Wswitch-default
#    -Wformat
    -Wdouble-promotion
    -Wredundant-decls
    -Wshadow
#    -Wcast-align
    -Wnull-dereference
    -Wno-format-extra-args
    -Wno-unused-function
    -Wno-unused-parameter
    -Wno-unused-label
    -Wno-missing-field-initializers
    -Wno-return-type)
