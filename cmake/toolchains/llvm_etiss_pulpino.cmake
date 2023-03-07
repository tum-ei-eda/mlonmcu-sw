# Contains toolchain configurations and settings for using LLVM/Clang

INCLUDE(LookupClang)

SET(CMAKE_C_COMPILER ${CLANG_EXECUTABLE})
SET(CMAKE_CXX_COMPILER ${CLANG++_EXECUTABLE})
SET(CMAKE_ASM_COMPILER ${CLANG_EXECUTABLE})
# set(CMAKE_C_LINKER lld-13) # TODO(fabianpedd): doesnt work, need to use -fuse-ld=lld-13 instead

IF(RISCV_VEXT)
    IF(NOT DEFINED RISCV_RVV_MAJOR OR NOT DEFINED RISCV_RVV_MINOR)
        MESSAGE(FATAL_ERROR "RISCV_VEXT requires RISCV_RVV_MAJOR and RISCV_RVV_MINOR")
    ENDIF()
    SET(RISCV_ARCH_FULL "${RISCV_ARCH}${RISCV_RVV_MAJOR}p${RISCV_RVV_MINOR}")
ELSE()
    SET(RISCV_ARCH_FULL ${RISCV_ARCH})
ENDIF()

SET(CMAKE_C_FLAGS
    "${CMAKE_C_FLAGS} --target=riscv32 -march=${RISCV_ARCH_FULL} -mabi=${RISCV_ABI} -menable-experimental-extensions -mno-relax"
)
SET(CMAKE_C_FLAGS
    "${CMAKE_C_FLAGS} --gcc-toolchain=${RISCV_ELF_GCC_PREFIX} --sysroot=${RISCV_ELF_GCC_PREFIX}/${RISCV_ELF_GCC_BASENAME}"
)

SET(CMAKE_CXX_FLAGS
    "${CMAKE_CXX_FLAGS} --target=riscv32 -march=${RISCV_ARCH_FULL} -mabi=${RISCV_ABI} -menable-experimental-extensions -mno-relax"
)
SET(CMAKE_CXX_FLAGS
    "${CMAKE_CXX_FLAGS} --gcc-toolchain=${RISCV_ELF_GCC_PREFIX} --sysroot=${RISCV_ELF_GCC_PREFIX}/${RISCV_ELF_GCC_BASENAME}"
)

SET(CMAKE_ASM_FLAGS
    "${CMAKE_ASM_FLAGS} --target=riscv32 -march=${RISCV_ARCH_FULL} -mabi=${RISCV_ABI} -menable-experimental-extensions -mno-relax"
)
SET(CMAKE_ASM_FLAGS
    "${CMAKE_ASM_FLAGS} --gcc-toolchain=${RISCV_ELF_GCC_PREFIX} --sysroot=${RISCV_ELF_GCC_PREFIX}/${RISCV_ELF_GCC_BASENAME}"
)

SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fuse-ld=lld")

IF(RISCV_AUTO_VECTORIZE)
   IF(NOT RISCV_VEXT)
       MESSAGE(FATAL_ERROR "RISCV_AUTO_VECTORIZE requires RISCV_VEXT")
   ENDIF()
   IF(RISCV_RVV_VLEN)
       SET(VLEN ${RISCV_RVV_VLEN})
   ELSE()
       SET(VLEN "?")
   ENDIF()
    SET(CMAKE_CXX_FLAGS_RELEASE
        "${CMAKE_CXX_FLAGS_RELEASE} \
        -mllvm \
        --riscv-v-vector-bits-min=${VLEN} \
    "
    )
    SET(CMAKE_C_FLAGS_RELEASE
        "${CMAKE_C_FLAGS_RELEASE} \
        -mllvm \
        --riscv-v-vector-bits-min=${VLEN} \
    "
    )
ENDIF()
