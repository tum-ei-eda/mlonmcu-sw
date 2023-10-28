# Contains toolchain configurations and settings for using LLVM/Clang
SET(TC_VARS
    RISCV_ELF_GCC_PREFIX
    RISCV_ELF_GCC_BASENAME
    RISCV_ARCH
    RISCV_ABI
    LLVM_DIR
    FEATURE_EXTRA_C_FLAGS
    FEATURE_EXTRA_CXX_FLAGS
    FEATURE_EXTRA_ASM_FLAGS
    CMAKE_C_COMPILER
    CMAKE_CXX_COMPILER
    CMAKE_ASM_COMPILER
    CMAKE_OBJCOPY
    CMAKE_OBJDUMP
)


INCLUDE(LookupClang OPTIONAL RESULT_VARIABLE LOOKUP_CLANG_MODULE)

IF(LOOKUP_CLANG_MODULE)
    SET(CMAKE_C_COMPILER ${CLANG_EXECUTABLE})
    SET(CMAKE_CXX_COMPILER ${CLANGPP_EXECUTABLE})
    SET(CMAKE_ASM_COMPILER ${CLANG_EXECUTABLE})
    SET(CMAKE_OBJCOPY ${LLVM_OBJCOPY_EXECUTABLE})
    SET(CMAKE_OBJDUMP ${LLVM_OBJDUMP_EXECUTABLE})
ENDIF()

SET(LLVM_VERSION_MAJOR 14)  # TODO: should not be hardcoded

IF(LLVM_VERSION_MAJOR LESS 13)
    MESSAGE(FATAL_ERROR "LLVM version 13 or higher is required")
ENDIF()


# The linker argument setting below will break the cmake test program on 64-bit, so disable test program linking for
# now.
SET(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

# the following is transferred from https://github.com/pulp-platform/ara/blob/main/apps/common/runtime.mk#L85-L93
# -march=$(RISCV_ARCH) -mabi=$(RISCV_ABI) $(DEFINES) -T/.../link.ld is added with 'add_definition' in corresponding cmake in target folder"
SET(RISCV_WARNINGS "${RISCV_WARNINGS} -Wunused-variable -Wall -Wextra -Wno-unused-command-line-argument") # -Werror
SET(LLVM_FLAGS "${LLVM_FLAGS} -menable-experimental-extensions -mno-relax -fuse-ld=lld")
SET(LLVM_V_FLAGS "${LLVM_V_FLAGS} -fno-vectorize -mllvm -scalable-vectorization=off -mllvm -riscv-v-vector-bits-min=0 -Xclang -target-feature -Xclang +no-optimized-zero-stride-load")

SET(RISCV_FLAGS "${LLVM_FLAGS} ${LLVM_V_FLAGS} ${RISCV_WARNINGS} -mcmodel=medany -static -ffast-math -fno-common")
# the following line is not in the ara repo, it is added so that stdc lib can be used
SET(RISCV_FLAGS "${RISCV_FLAGS} -lstdc++ --gcc-toolchain=${RISCV_ELF_GCC_PREFIX}  --sysroot=${RISCV_ELF_GCC_PREFIX}/${RISCV_ELF_GCC_BASENAME}")

SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${RISCV_FLAGS} -std=gnu99 -ffunction-sections -fdata-sections")

SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${RISCV_FLAGS} -ffunction-sections -fdata-sections")

SET(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} ${RISCV_FLAGS} -std=gnu99 -ffunction-sections -fdata-sections")

SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Iinclude ${RISCV_FLAGS} -march=${RISCV_ARCH} -mabi=${RISCV_ABI}  -menable-experimental-extensions   -std=gnu99 -ffunction-sections -fdata-sections -static -nostartfiles -lm -Wl,--gc-sections -fuse-ld=lld")
# end of transferred from https://github.com/pulp-platform/ara/blob/main/apps/common/runtime.mk#L85-L93

SET(FUSE_LD
    "lld"
    CACHE STRING "fuse-ld value"
)

IF(NOT "${FUSE_LD}" STREQUAL "" AND NOT "${FUSE_LD}" STREQUAL "none")
    SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fuse-ld=${FUSE_LD}")
ENDIF()

foreach(X IN ITEMS ${EXTRA_CMAKE_C_FLAGS} ${FEATURE_EXTRA_C_FLAGS})
    add_compile_options("SHELL:$<$<COMPILE_LANGUAGE:C>:${X}>")
endforeach()
foreach(X IN ITEMS ${EXTRA_CMAKE_CXX_FLAGS} ${FEATURE_EXTRA_CXX_FLAGS})
    add_compile_options("SHELL:$<$<COMPILE_LANGUAGE:CXX>:${X}>")
endforeach()
foreach(X IN ITEMS ${EXTRA_CMAKE_ASM_FLAGS} ${FEATURE_EXTRA_ASM_FLAGS})
    add_compile_options("SHELL:$<$<COMPILE_LANGUAGE:ASM>:${X}>")
endforeach()
