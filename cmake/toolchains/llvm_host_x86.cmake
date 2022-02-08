# Contains toolchain configurations and settings for using LLVM/Clang

# Lets stick to standard .elf file ending for now
# set(CMAKE_EXECUTABLE_SUFFIX_C .elf)

# Path to your RISC-V GCC compiler (only used to get the headers and libraries, actual compiler is LLVM/Clang)
set(RISCV_GCC_PREFIX "/opt/riscv" CACHE PATH "Install location of GCC RISC-V toolchain.")
set(RISCV_GCC_BASENAME "riscv32-unknown-elf" CACHE STRING "Base name of the toolchain executables.")

# Set the desired architecture and application binary interface
# For more info on these, see here https://www.sifive.com/blog/all-aboard-part-1-compiler-args
set(RISCV_ARCH "rv32gcv0p10" CACHE STRING "march argument to the compiler")
set(RISCV_ABI "ilp32d" CACHE STRING "mabi argument to the compiler")

set(CMAKE_C_COMPILER clang-13)
set(CMAKE_ASM_COMPILER clang-13)
# set(CMAKE_C_LINKER lld-13) # TODO(fabianpedd): doesnt work, need to use -fuse-ld=lld-13 instead

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --target=riscv32 -march=${RISCV_ARCH} -mabi=${RISCV_ABI} -menable-experimental-extensions -mno-relax")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --gcc-toolchain=${RISCV_GCC_PREFIX} --sysroot=${RISCV_GCC_PREFIX}/${RISCV_GCC_BASENAME}")

set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} --target=riscv32 -march=${RISCV_ARCH} -mabi=${RISCV_ABI} -menable-experimental-extensions -mno-relax")
set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} --gcc-toolchain=${RISCV_GCC_PREFIX} --sysroot=${RISCV_GCC_PREFIX}/${RISCV_GCC_BASENAME}")

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fuse-ld=lld-13")
