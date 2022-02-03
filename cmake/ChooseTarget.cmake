# New target architectures and systems should be added here Make sure to define the CMAKE_TOOLCHAIN_FILE for
# cross-compilation

# Default implementation of the macro points to the original ADD_LIBRARY function
MACRO(COMMON_ADD_LIBRARY TARGET_NAME)
    ADD_LIBRARY(${TARGET_NAME} ${ARGN})
ENDMACRO()

MACRO(COMMON_ADD_EXECUTABLE TARGET_NAME)
    ADD_EXECUTABLE(${TARGET_NAME} ${ARGN})
ENDMACRO()

IF(TARGET_SYSTEM STREQUAL "etiss_pulpino")
    SET(ETISS_DIR
        "/usr/local/research/projects/SystemDesign/tools/etiss/current"  # TODO: remove
        CACHE STRING "Directory of ETISS"
    )
    SET(PULPINO_TC_DIR ${ETISS_DIR}/examples/SW/riscv/cmake)
    SET(CMAKE_TOOLCHAIN_FILE "${PULPINO_TC_DIR}/pulpino_tumeda/toolchain.cmake")
    ADD_DEFINITIONS(-DPULPINO_NO_GPIO)
    SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PULPINO_TC_DIR}")
    IF(NOT PULPINO_ROM_START)
        SET(PULPINO_ROM_START 0x0)
    ENDIF()
    IF(NOT PULPINO_ROM_SIZE)
        SET(PULPINO_ROM_SIZE 0x100000)
    ENDIF()
    IF(NOT PULPINO_RAM_START)
        SET(PULPINO_RAM_START 0x100000)
    ENDIF()
    IF(NOT PULPINO_RAM_SIZE)
        SET(PULPINO_RAM_SIZE 0x200000)
    ENDIF()
    SET(PULPINO_MIN_STACK_SIZE 0x4000)
    SET(PULPINO_MIN_HEAP_SIZE 0x4000)
    SET(ETISS_LOGGER_ADDR 0xf0000000)

    INCLUDE(PulpinoTarget)
    MACRO(COMMON_ADD_LIBRARY TARGET_NAME)
        ADD_LIBRARY_PULPINO(${TARGET_NAME} ${ARGN})
    ENDMACRO()
    MACRO(COMMON_ADD_EXECUTABLE TARGET_NAME)
        SET(ARGS "${ARGN}")
        SET(SRC_FILES ${ARGS})
        ADD_EXECUTABLE_PULPINO(${TARGET_NAME} ${ARGN})
    ENDMACRO()

    ADD_DEFINITIONS(BUILDING_FOR_ETISS)
ELSEIF(TARGET_SYSTEM STREQUAL "corstone300")
    # Nothing to do...

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
    set(CMAKE_EXECUTABLE_SUFFIX ".elf")
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
ELSEIF(TARGET_SYSTEM STREQUAL "host_x86")
    # Nothing to do...
ELSEIF(TARGET_SYSTEM STREQUAL "generic_riscv")
    set(CMAKE_SYSTEM_NAME Generic)
    set(RISCV_ELF_GCC_PREFIX "" CACHE PATH "install location for riscv-gcc toolchain")
    set(RISCV_ELF_GCC_BASENAME "riscv64-unknown-elf" CACHE STRING "base name of the toolchain executables")
    set(RISCV_ARCH "rv32gc" CACHE STRING "march argument to the compiler")
    # set(RISCV_ARCH "rv32gcv" CACHE STRING "march argument to the compiler")
    set(RISCV_ABI "ilp32d" CACHE STRING "mabi argument to the compiler")

    set(TC_PREFIX "${RISCV_ELF_GCC_PREFIX}/bin/${RISCV_ELF_GCC_BASENAME}-")
    set(CMAKE_C_COMPILER ${TC_PREFIX}gcc${EXE_EXT})
    set(CMAKE_CXX_COMPILER ${TC_PREFIX}g++${EXE_EXT})
    set(CMAKE_ASM_COMPILER ${TC_PREFIX}gcc${EXE_EXT})
    set(CMAKE_LINKER ${TC_PREFIX}ld${EXE_EXT})
    set(CMAKE_OBJCOPY ${TC_PREFIX}objcopy${EXE_EXT})
    set(CMAKE_AR ${TC_PREFIX}ar${EXE_EXT})
    set(CMAKE_RANLIB ${TC_PREFIX}ranlib${EXE_EXT})
    add_definitions(-D__riscv__)
    add_definitions(-march=${RISCV_ARCH})
    add_definitions(-mabi=${RISCV_ABI})

    # The linker argument setting below will break the cmake test program on 64-bit, so disable test program linking for now.
    set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -march=${RISCV_ARCH} -mabi=${RISCV_ABI}")
ELSE()
    MESSAGE(FATAL_ERROR "The chosen value '${TARGET_SYSTEM}' for TARGET_SYSTEM is invalid.")
ENDIF()
