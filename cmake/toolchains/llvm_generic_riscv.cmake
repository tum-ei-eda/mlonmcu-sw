# Contains toolchain configurations and settings for using LLVM/Clang

set(CMAKE_C_COMPILER clang-13)
set(CMAKE_CXX_COMPILER clang++-13)
set(CMAKE_ASM_COMPILER clang-13)
# set(CMAKE_C_LINKER lld-13) # TODO(fabianpedd): doesnt work, need to use -fuse-ld=lld-13 instead

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --target=riscv32 -march=${RISCV_ARCH} -mabi=${RISCV_ABI} -menable-experimental-extensions -mno-relax")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --gcc-toolchain=${RISCV_ELF_GCC_PREFIX} --sysroot=${RISCV_ELF_GCC_PREFIX}/${RISCV_ELF_GCC_BASENAME}")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --target=riscv32 -march=${RISCV_ARCH} -mabi=${RISCV_ABI} -menable-experimental-extensions -mno-relax")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --gcc-toolchain=${RISCV_ELF_GCC_PREFIX} --sysroot=${RISCV_ELF_GCC_PREFIX}/${RISCV_ELF_GCC_BASENAME}")

set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} --target=riscv32 -march=${RISCV_ARCH} -mabi=${RISCV_ABI} -menable-experimental-extensions -mno-relax")
set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} --gcc-toolchain=${RISCV_ELF_GCC_PREFIX} --sysroot=${RISCV_ELF_GCC_PREFIX}/${RISCV_ELF_GCC_BASENAME}")

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fuse-ld=lld-13")
