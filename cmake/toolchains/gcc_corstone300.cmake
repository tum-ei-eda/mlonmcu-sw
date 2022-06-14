# Setting Linux is forcing th extension to be .o instead of .obj when building on WIndows.
# It is important because armlink is failing when files have .obj extensions (error with
# scatter file section not found)
# SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SYSTEM_NAME Generic)
# SET(CMAKE_SYSTEM_PROCESSOR cortex-m55)

IF(WIN32)
    set(EXE_EXT ".exe")
ENDIF()

set(ARM_COMPILER_PREFIX "" CACHE PATH "install location for gcc toolchain")
set(ARM_COMPILER_BASENAME "arm-none-eabi" CACHE STRING "base name of the toolchain executables")

IF(NOT TC_PREFIX)
    IF("${ARM_COMPILER_PREFIX}" STREQUAL "")
        set(TC_PREFIX "${ARM_COMPILER_BASENAME}-")
    ELSE()
        set(TC_PREFIX "${ARM_COMPILER_PREFIX}/bin/${ARM_COMPILER_BASENAME}-")
    ENDIF()
ENDIF()

set(CMAKE_C_COMPILER ${TC_PREFIX}gcc${EXE_EXT})
set(CMAKE_CXX_COMPILER ${TC_PREFIX}g++${EXE_EXT})
set(CMAKE_OBJCOPY ${TC_PREFIX}objcopy${EXE_EXT})
set(CMAKE_AR ${TC_PREFIX}ar${EXE_EXT})
set(CMAKE_C_COMPILER_AR ${TC_PREFIX}ar${EXE_EXT})
set(CMAKE_CXX_COMPILER_AR ${TC_PREFIX}ar${EXE_EXT})

# TODO: Use Find_Program?

#SET(CMAKE_LINKER "${tools}/bin/arm-none-eabi-g++")
#find_program(CMAKE_LINKER NAMES arm-none-eabi-g++ arm-none-eabi-g++.exe)
#
#SET(CMAKE_C_LINK_EXECUTABLE "<CMAKE_LINKER> <LINK_FLAGS> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>")
#SET(CMAKE_CXX_LINK_EXECUTABLE "<CMAKE_LINKER> <LINK_FLAGS> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>")
#SET(CMAKE_C_OUTPUT_EXTENSION .o)
#SET(CMAKE_CXX_OUTPUT_EXTENSION .o)
#SET(CMAKE_ASM_OUTPUT_EXTENSION .o)
## When library defined as STATIC, this line is needed to describe how the .a file must be
## create. Some changes to the line may be needed.
#SET(CMAKE_C_CREATE_STATIC_LIBRARY "<CMAKE_AR> -crs <TARGET> <LINK_FLAGS> <OBJECTS>" )
#SET(CMAKE_CXX_CREATE_STATIC_LIBRARY "<CMAKE_AR> -crs <TARGET> <LINK_FLAGS> <OBJECTS>" )

#set(GCC ON)
# default core

if(NOT ARM_CPU)
    set(
            # ARM_CPU "cortex-a5"
            ARM_CPU "cortex-m55"
            CACHE STRING "Set ARM CPU. Default : cortex-a5"
    )
endif(NOT ARM_CPU)

if (ARM_CPU STREQUAL "cortex-m55")
# For gcc 10q4
SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -ffunction-sections -fdata-sections -march=armv8.1-m.main+mve.fp+fp.dp -mfloat-abi=hard -mcpu=${ARM_CPU}" CACHE INTERNAL "C compiler common flags")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffunction-sections -fdata-sections -march=armv8.1-m.main+mve.fp+fp.dp -mfloat-abi=hard -mcpu=${ARM_CPU}" CACHE INTERNAL "C++ compiler common flags")
SET(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -march=armv8.1-m.main+mve.fp+fp.dp -mfloat-abi=hard -mcpu=${ARM_CPU}" CACHE INTERNAL "ASM compiler common flags")
SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fno-use-linker-plugin -march=armv8.1-m.main+mve.fp+fp.dp"  CACHE INTERNAL "linker flags")
else()
SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -ffunction-sections -fdata-sections -mcpu=${ARM_CPU}" CACHE INTERNAL "C compiler common flags")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffunction-sections -fdata-sections -mcpu=${ARM_CPU}" CACHE INTERNAL "C+ compiler common flags")
SET(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -mcpu=${ARM_CPU}" CACHE INTERNAL "ASM compiler common flags")
SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -mcpu=${ARM_CPU}"  CACHE INTERNAL "linker flags")
endif()

get_property(IS_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE)
if(IS_IN_TRY_COMPILE)
    add_link_options("--specs=nosys.specs")
endif()
add_link_options("--specs=nosys.specs")

add_link_options("-Wl,--start-group")
#add_link_options("-mcpu=${ARM_CPU}")

# Where is the target environment
#SET(CMAKE_FIND_ROOT_PATH "${tools}")
# Search for programs in the build host directories
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# For libraries and headers in the target directories
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

