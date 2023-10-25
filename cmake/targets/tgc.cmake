SET(CMAKE_SYSTEM_NAME Generic)

# Fully featured RISC-V core with vector extension
#SET(CMAKE_SYSTEM_PROCESSOR rv32imc)

SET(RISCV_ELF_GCC_PREFIX
    ""
    CACHE PATH "install location for riscv-gcc toolchain"
)
SET(RISCV_ELF_GCC_BASENAME
    "riscv32-unknown-elf"
    CACHE STRING "base name of the toolchain executables"
)
SET(RISCV_ARCH
    "rv32imc"
    CACHE STRING "march argument to the compiler" FORCE
)
# set(RISCV_ARCH "rv32" CACHE STRING "march argument to the compiler" FORCE)
SET(RISCV_ABI
    "ilp32"
    CACHE STRING "mabi argument to the compiler" FORCE
)
SET(TC_PREFIX "${RISCV_ELF_GCC_PREFIX}/bin/${RISCV_ELF_GCC_BASENAME}-")

#SET(RISCV_ATTR "" CACHE STRING "set empty attr" FORCE)

INCLUDE(/home/gabriel/mlonmcu-sw/mlonmcu-sw/cmake/targets/tgc/CMakeLists.txt)

MACRO(COMMON_ADD_EXECUTABLE TARGET)

#INCLUDE(${CMAKE_CURRENT_LIST_DIR}/../cmake/targets/tgc/LibWrap.cmake)

# Variables from Makefile
SET(BSP_BASE ${CMAKE_CURRENT_LIST_DIR}/../cmake/targets/tgc)
SET(BOARD "iss" CACHE STRING "Board")
SET(ENV_DIR ${BSP_BASE}/env)
SET(PLATFORM_DIR ${ENV_DIR}/${BOARD})

# Source files
SET(ASM_SRCS
    ${ENV_DIR}/entry.S
    ${ENV_DIR}/start.S
)
SET(C_SRCS
    ${PLATFORM_DIR}/init.c
)
SET_SOURCE_FILES_PROPERTIES(${ASM_SRCS} PROPERTIES LANGUAGE C)

# Compiler Flags
SET(COMMON_FLAGS "")

# GCC Version Check
EXECUTE_PROCESS(
    COMMAND ${CMAKE_C_COMPILER} --version
    OUTPUT_VARIABLE GCC_VERSION
)
IF(GCC_VERSION MATCHES "9.2")
    LIST(APPEND COMMON_FLAGS "-march=${RISCV_ARCH}")
ELSE()
    LIST(APPEND COMMON_FLAGS "-march=${RISCV_ARCH}_zicsr_zifencei")
ENDIF()
LIST(APPEND COMMON_FLAGS "-mabi=${RISCV_ABI}" "-mcmodel=medany")

# Includes
INCLUDE_DIRECTORIES(
    ${BSP_BASE}/include
    ${BSP_BASE}/drivers
    ${ENV_DIR}
    ${PLATFORM_DIR}
)

# Compiler Options
ADD_COMPILE_OPTIONS("${COMMON_FLAGS}")

# Targets
SET(SRC_FILES "${ARGN}")

ADD_EXECUTABLE(${TARGET} ${ASM_SRCS} ${C_SRCS} ${SRC_FILES})
SET_TARGET_PROPERTIES(${TARGET} PROPERTIES LINKER_LANGUAGE C)

TARGET_LINK_LIBRARIES(${TARGET} PUBLIC ${LIBWRAP_TGC_LDFLAGS} LIBWRAP_TGC)

# Linker Flags
TARGET_LINK_LIBRARIES(${TARGET}
    PUBLIC
        -march=${RISCV_ARCH} -mabi=${RISCV_ABI}
        -T ${PLATFORM_DIR}/link.lds
        -Wl,-Map=${TARGET}.map
        -nostartfiles
        -L${ENV_DIR}
)


ENDMACRO()

MACRO(COMMON_ADD_LIBRARY TARGET_NAME)
    message(STATUS "Source files for ${TARGET_NAME}: ${ARGN}")
    ADD_LIBRARY(${TARGET_NAME} ${ARGN})
    # Setting the common compile flags
    TARGET_COMPILE_OPTIONS(${TARGET_NAME} PRIVATE -march=${RISCV_ARCH}_zicsr_zifencei -mabi=${RISCV_ABI})

    TARGET_LINK_OPTIONS(${TARGET_NAME} PRIVATE -march=${RISCV_ARCH}_zicsr_zifencei -mabi=${RISCV_ABI})
ENDMACRO()