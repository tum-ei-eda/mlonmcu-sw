# Contains toolchain configurations and settings for using LLVM/Clang

INCLUDE(LookupClang)

SET(CMAKE_C_COMPILER ${CLANG_EXECUTABLE})
SET(CMAKE_CXX_COMPILER ${CLANG++_EXECUTABLE})
SET(CMAKE_ASM_COMPILER ${CLANG_EXECUTABLE})
# TODO: automatic lookup with find_program

SET(OBJDUMP_EXTRA_ARGS "--mattr=${RISCV_ATTR}")

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
    "${CMAKE_C_FLAGS} --target=riscv32 -march=${RISCV_ARCH_FULL} -mabi=${RISCV_ABI}"
)
SET(CMAKE_C_FLAGS
    "${CMAKE_C_FLAGS} --gcc-toolchain=${RISCV_ELF_GCC_PREFIX} --sysroot=${RISCV_ELF_GCC_PREFIX}/${RISCV_ELF_GCC_BASENAME}"
)
SET(CMAKE_C_FLAGS
    "${CMAKE_C_FLAGS} ${FEATURE_EXTRA_C_FLAGS}"
)
SET(CMAKE_CXX_FLAGS
    "${CMAKE_CXX_FLAGS} --target=riscv32 -march=${RISCV_ARCH_FULL} -mabi=${RISCV_ABI}"
)
SET(CMAKE_CXX_FLAGS
    "${CMAKE_CXX_FLAGS} --gcc-toolchain=${RISCV_ELF_GCC_PREFIX} --sysroot=${RISCV_ELF_GCC_PREFIX}/${RISCV_ELF_GCC_BASENAME}"
)
SET(CMAKE_CXX_FLAGS
    "${CMAKE_CXX_FLAGS} ${FEATURE_EXTRA_CXX_FLAGS}"
)
SET(CMAKE_ASM_FLAGS
    "${CMAKE_ASM_FLAGS} --target=riscv32 -march=${RISCV_ARCH_FULL} -mabi=${RISCV_ABI}"
)
SET(CMAKE_ASM_FLAGS
    "${CMAKE_ASM_FLAGS} --gcc-toolchain=${RISCV_ELF_GCC_PREFIX} --sysroot=${RISCV_ELF_GCC_PREFIX}/${RISCV_ELF_GCC_BASENAME}"
)
SET(CMAKE_ASM_FLAGS
    "${CMAKE_ASM_FLAGS} ${FEATURE_EXTRA_ASM_FLAGS}"
)

SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fuse-ld=lld")
