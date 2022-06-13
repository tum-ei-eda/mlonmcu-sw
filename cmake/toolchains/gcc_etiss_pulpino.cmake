# Copy-pasted from ETISS repo
set(CMAKE_SYSTEM_NAME Generic)

# RV32GC processor
set(CMAKE_SYSTEM_PROCESSOR Pulpino)

set(CMAKE_C_COMPILER ${TC_PREFIX}gcc${EXE_EXT})
set(CMAKE_CXX_COMPILER ${TC_PREFIX}g++${EXE_EXT})
set(CMAKE_ASM_COMPILER ${TC_PREFIX}gcc${EXE_EXT})
set(CMAKE_LINKER ${TC_PREFIX}ld${EXE_EXT})
set(CMAKE_OBJCOPY ${TC_PREFIX}objcopy${EXE_EXT})
set(CMAKE_AR ${TC_PREFIX}ar${EXE_EXT})
set(CMAKE_RANLIB ${TC_PREFIX}ranlib${EXE_EXT})

# The linker argument setting below will break the cmake test program on 64-bit, so disable test program linking for now.
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -march=${RISCV_ARCH} -mabi=${RISCV_ABI}")
