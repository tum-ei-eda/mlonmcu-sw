
# The Generic system name is used for bare-metal targets (without OS) in CMake
set(CMAKE_SYSTEM_NAME Generic)

# Fully featured RISC-V core with vector extension
set(CMAKE_SYSTEM_PROCESSOR rv32mafdc)

set(RISCV_ELF_GCC_PREFIX "" CACHE PATH "install location for riscv-gcc toolchain")
set(RISCV_ELF_GCC_BASENAME "riscv64-unknown-elf" CACHE STRING "base name of the toolchain executables")
set(RISCV_ARCH "rv32gc" CACHE STRING "march argument to the compiler")
# set(RISCV_ARCH "rv32gcv" CACHE STRING "march argument to the compiler")
set(RISCV_ABI "ilp32d" CACHE STRING "mabi argument to the compiler")
set(TC_PREFIX "${RISCV_ELF_GCC_PREFIX}/bin/${RISCV_ELF_GCC_BASENAME}-")

# The linker argument setting below will break the cmake test program on 64-bit, so disable test program linking for now.
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -march=${RISCV_ARCH} -mabi=${RISCV_ABI}")

add_definitions(-D__riscv__)
add_definitions(-march=${RISCV_ARCH})
add_definitions(-mabi=${RISCV_ABI})

set(QEMU_SIFIVE_SUPPORT_DIR "${CMAKE_CURRENT_LIST_DIR}/qemu_sifive_support")

MACRO(COMMON_ADD_EXECUTABLE TARGET_NAME)
    SET(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

    SET(CMAKE_EXE_LINKER_FLAGS
        "${CMAKE_EXE_LINKER_FLAGS} -nostartfiles \
        -T ${QEMU_SIFIVE_SUPPORT_DIR}/link.ld"
    )
        # -L ${PULPI}/ref/ \

    # SET(CMAKE_TOOLCHAIN_FILE
    #     "${PULPINO_LIB_TUMEDA}/toolchain.cmake"
    # )

    # PROJECT(${TARGET_NAME} LANGUAGES C CXX ASM)
    PROJECT(${TARGET_NAME} LANGUAGES C ASM)

    SET(ARGS "${ARGN}")
    SET(SRC_FILES ${ARGS})
    IF(${ADD_PLATFORM_FILES})
        LIST(APPEND SRC_FILES
            ${QEMU_SIFIVE_SUPPORT_DIR}/start.s
        )
    ENDIF()

    ADD_EXECUTABLE(${TARGET_NAME} ${SRC_FILES})

    SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES LINK_DEPENDS ${QEMU_SIFIVE_SUPPORT_DIR}/link.ld)
ENDMACRO()
