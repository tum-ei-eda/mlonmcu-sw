# The Generic system name is used for bare-metal targets (without OS) in CMake
SET(CMAKE_SYSTEM_NAME Generic)

# Fully featured RISC-V core with vector extension
SET(CMAKE_SYSTEM_PROCESSOR rv32imc)

SET(RISCV_ELF_GCC_PREFIX
    ""
    CACHE PATH "install location for riscv-gcc toolchain"
)
SET(RISCV_ELF_GCC_BASENAME
    "riscv64-unknown-elf"
    CACHE STRING "base name of the toolchain executables"
)
SET(RISCV_ARCH
    "rv32imc"
    CACHE STRING "march argument to the compiler"
)
# set(RISCV_ARCH "rv32gcv" CACHE STRING "march argument to the compiler")
SET(RISCV_ABI
    "ilp32"
    CACHE STRING "mabi argument to the compiler"
)
SET(TC_PREFIX "${RISCV_ELF_GCC_PREFIX}/bin/${RISCV_ELF_GCC_BASENAME}-")

# The linker argument setting below will break the cmake test program on 64-bit, so disable test program linking for
# now.
SET(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -march=${RISCV_ARCH} -mabi=${RISCV_ABI}")

ADD_DEFINITIONS(-D__riscv__)
ADD_DEFINITIONS(-march=${RISCV_ARCH})
ADD_DEFINITIONS(-mabi=${RISCV_ABI})

# Linker file settings.
SET(LINK_FILE "${CMAKE_CURRENT_LIST_DIR}/cv32e40p/link.ld")
SET(LINK_FILE_OPTION "-T")

SET(BOOT_SRCS ${CMAKE_CURRENT_LIST_DIR}/cv32e40p/crt0.S ${CMAKE_CURRENT_LIST_DIR}/cv32e40p/syscalls.c ${CMAKE_CURRENT_LIST_DIR}/cv32e40p/vectors.S ${CMAKE_CURRENT_LIST_DIR}/cv32e40p/handlers.S)

MACRO(COMMON_ADD_EXECUTABLE TARGET_NAME)
    ADD_EXECUTABLE(${TARGET_NAME} ${ARGN} ${BOOT_SRCS})
    TARGET_COMPILE_OPTIONS(${TARGET_NAME} PUBLIC
        $<$<COMPILE_LANGUAGE:CXX>:-std=c++17>
        $<$<COMPILE_LANGUAGE:C>:-std=gnu99>
    )
    TARGET_LINK_OPTIONS(${TARGET_NAME} PRIVATE ${LINK_FILE_OPTION} ${LINK_FILE})
    SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES LINK_DEPENDS ${LINK_FILE})
    # TARGET_LINK_OPTIONS(${TARGET_NAME} PRIVATE "--specs=nosys.specs")
    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O verilog  ${CMAKE_BINARY_DIR}/bin/${TARGET_NAME} ${CMAKE_BINARY_DIR}/bin/${TARGET_NAME}.hex
        COMMENT "Invoking: Hexdump")
ENDMACRO()

MACRO(COMMON_ADD_LIBRARY TARGET_NAME)
    ADD_LIBRARY(${TARGET_NAME} ${ARGN})
    # TARGET_LINK_LIBRARIES(${TARGET_NAME} PRIVATE femto)
    # ADD_DEPENDENCIES(${TARGET_NAME} femto)
    # TARGET_COMPILE_OPTIONS(${TARGET_NAME} PUBLIC
    #     $<$<COMPILE_LANGUAGE:CXX>:-std=c++17>
    #     $<$<COMPILE_LANGUAGE:C>:-std=gnu99>
    # )
    # IF("${ARGV1}" STREQUAL "OBJECT" AND "${ARGV2}" STREQUAL "IMPORTED")
    # ELSE()
    # ENDIF()
ENDMACRO()

SET(CMAKE_EXE_LINKER_FLAGS
    "${CMAKE_EXE_LINKER_FLAGS} -nostartfiles"
)

SET(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

IF("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    ADD_DEFINITIONS(-DDEBUG_SYSTEM)
ENDIF()

IF(RISCV_VEXT)
    ADD_DEFINITIONS(-DUSE_VEXT)
ENDIF()
