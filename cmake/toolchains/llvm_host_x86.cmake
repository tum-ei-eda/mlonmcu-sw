SET(TC_VARS
    LLVM_DIR
)
# Contains toolchain configurations and settings for using LLVM/Clang

# Lets stick to standard .elf file ending for now set(CMAKE_EXECUTABLE_SUFFIX_C .elf)

INCLUDE(LookupClang)

SET(CMAKE_C_COMPILER ${CLANG_EXECUTABLE})
SET(CMAKE_CXX_COMPILER ${CLANG++_EXECUTABLE})
SET(CMAKE_ASM_COMPILER ${CLANG_EXECUTABLE})
# TODO: automatic lookup with find_program

SET(LLVM_VERSION_MAJOR 14)  # TODO: should not be hardcoded

IF(LLVM_VERSION_MAJOR LESS 13)
    MESSAGE(FATAL_ERROR "LLVM version 13 or higher is required")
ENDIF()
# set(CMAKE_C_LINKER lld-13) # TODO(fabianpedd): doesnt work, need to use -fuse-ld=lld-13 instead

# SET(CMAKE_C_FLAGS
#     "${CMAKE_C_FLAGS} --target=riscv32 -march=${RISCV_ARCH} -mabi=${RISCV_ABI} -menable-experimental-extensions -mno-relax"
# )
# SET(CMAKE_C_FLAGS
#     "${CMAKE_C_FLAGS} --gcc-toolchain=${RISCV_GCC_PREFIX} --sysroot=${RISCV_GCC_PREFIX}/${RISCV_GCC_BASENAME}"
# )
#
# SET(CMAKE_ASM_FLAGS
#     "${CMAKE_ASM_FLAGS} --target=riscv32 -march=${RISCV_ARCH} -mabi=${RISCV_ABI} -menable-experimental-extensions -mno-relax"
# )
# SET(CMAKE_ASM_FLAGS
#     "${CMAKE_ASM_FLAGS} --gcc-toolchain=${RISCV_GCC_PREFIX} --sysroot=${RISCV_GCC_PREFIX}/${RISCV_GCC_BASENAME}"
# )
#
# SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fuse-ld=lld-13")
