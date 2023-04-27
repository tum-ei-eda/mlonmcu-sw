SET(TC_VARS
    RISCV_ELF_GCC_PREFIX
    RISCV_ELF_GCC_BASENAME
    RISCV_ARCH
    RISCV_ABI
    LLVM_DIR
    FEATURE_EXTRA_C_FLAGS
    FEATURE_EXTRA_CXX_FLAGS
    FEATURE_EXTRA_ASM_FLAGS
)
SET(RISCV_ELF_GCC_PREFIX
    ""
    CACHE PATH "install location for riscv-gcc toolchain"
)
SET(RISCV_ELF_GCC_BASENAME
    "riscv64-unknown-elf"
    CACHE STRING "base name of the toolchain executables"
)
SET(RISCV_ARCH
    "rv32gc"
    CACHE STRING "march argument to the compiler"
)
SET(RISCV_ABI
    "ilp32d"
    CACHE STRING "mabi argument to the compiler"
)
STRING(SUBSTRING ${RISCV_ARCH} 2 2 XLEN)
SET(TC_PREFIX "${RISCV_ELF_GCC_PREFIX}/bin/${RISCV_ELF_GCC_BASENAME}-")

# Contains toolchain configurations and settings for using LLVM/Clang

INCLUDE(LookupClang)

SET(CMAKE_C_COMPILER ${CLANG_EXECUTABLE})
SET(CMAKE_CXX_COMPILER ${CLANG++_EXECUTABLE})
SET(CMAKE_ASM_COMPILER ${CLANG_EXECUTABLE})
# TODO: automatic lookup with find_program

SET(LLVM_VERSION_MAJOR 14)  # TODO: should not be hardcoded

IF(LLVM_VERSION_MAJOR LESS 13)
    MESSAGE(FATAL_ERROR "LLVM version 13 or higher is required")
ENDIF()


IF(RISCV_VEXT)
    IF(NOT DEFINED RISCV_RVV_MAJOR OR NOT DEFINED RISCV_RVV_MINOR)
        MESSAGE(FATAL_ERROR "RISCV_VEXT requires RISCV_RVV_MAJOR and RISCV_RVV_MINOR")
    ENDIF()
    SET(RISCV_ARCH_FULL "${RISCV_ARCH}${RISCV_RVV_MAJOR}p${RISCV_RVV_MINOR}")
    IF(LLVM_VERSION_MAJOR EQUAL 13)
        SET(CMAKE_C_FLAGS
            "${CMAKE_C_FLAGS} -menable-experimental-extensions -mno-relax"
        )
        SET(CMAKE_CXX_FLAGS
            "${CMAKE_CXX_FLAGS} -menable-experimental-extensions -mno-relax"
        )
        SET(CMAKE_ASM_FLAGS
            "${CMAKE_ASM_FLAGS} -menable-experimental-extensions -mno-relax"
        )
    ENDIF()
ELSE()
    SET(RISCV_ARCH_FULL ${RISCV_ARCH})
ENDIF()

SET(CMAKE_C_FLAGS
    "${CMAKE_C_FLAGS} --target=riscv${XLEN} -march=${RISCV_ARCH_FULL} -mabi=${RISCV_ABI}"
)
SET(CMAKE_C_FLAGS
    "${CMAKE_C_FLAGS} --gcc-toolchain=${RISCV_ELF_GCC_PREFIX} --sysroot=${RISCV_ELF_GCC_PREFIX}/${RISCV_ELF_GCC_BASENAME}"
)

SET(CMAKE_CXX_FLAGS
    "${CMAKE_CXX_FLAGS} --target=riscv${XLEN} -march=${RISCV_ARCH_FULL} -mabi=${RISCV_ABI}"
)
SET(CMAKE_CXX_FLAGS
    "${CMAKE_CXX_FLAGS} --gcc-toolchain=${RISCV_ELF_GCC_PREFIX} --sysroot=${RISCV_ELF_GCC_PREFIX}/${RISCV_ELF_GCC_BASENAME}"
)

SET(CMAKE_ASM_FLAGS
    "${CMAKE_ASM_FLAGS} --target=riscv${XLEN} -march=${RISCV_ARCH_FULL} -mabi=${RISCV_ABI}"
)
SET(CMAKE_ASM_FLAGS
    "${CMAKE_ASM_FLAGS} --gcc-toolchain=${RISCV_ELF_GCC_PREFIX} --sysroot=${RISCV_ELF_GCC_PREFIX}/${RISCV_ELF_GCC_BASENAME}"
)

# SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fuse-ld=lld")

SET(CMAKE_C_FLAGS
    "${CMAKE_C_FLAGS} ${FEATURE_EXTRA_C_FLAGS}"
)
SET(CMAKE_CXX_FLAGS
    "${CMAKE_CXX_FLAGS} ${FEATURE_EXTRA_CXX_FLAGS}"
)
SET(CMAKE_ASM_FLAGS
    "${CMAKE_ASM_FLAGS} ${FEATURE_EXTRA_ASM_FLAGS}"
)
