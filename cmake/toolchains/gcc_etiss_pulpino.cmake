# Copy-pasted from ETISS repo
SET(CMAKE_SYSTEM_NAME Generic)

# RV32GC processor
SET(CMAKE_SYSTEM_PROCESSOR Pulpino)

SET(CMAKE_C_COMPILER ${TC_PREFIX}gcc${EXE_EXT})
SET(CMAKE_CXX_COMPILER ${TC_PREFIX}g++${EXE_EXT})
SET(CMAKE_ASM_COMPILER ${TC_PREFIX}gcc${EXE_EXT})
SET(CMAKE_LINKER ${TC_PREFIX}ld${EXE_EXT})
SET(CMAKE_OBJCOPY ${TC_PREFIX}objcopy${EXE_EXT})
SET(CMAKE_AR ${TC_PREFIX}ar${EXE_EXT})
SET(CMAKE_RANLIB ${TC_PREFIX}ranlib${EXE_EXT})

# The linker argument setting below will break the cmake test program on 64-bit, so disable test program linking for
# now.
SET(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -march=${RISCV_ARCH} -mabi=${RISCV_ABI}")

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
        -mrvv \
        -ftree-vectorize \
        -mriscv-vector-bits=${VLEN} \
    "
    )
    SET(CMAKE_C_FLAGS_RELEASE
        "${CMAKE_C_FLAGS_RELEASE} \
        -mrvv \
        -ftree-vectorize \
        -mriscv-vector-bits=${VLEN} \
    "
    )
ENDIF()
