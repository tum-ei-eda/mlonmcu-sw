
# The Generic system name is used for bare-metal targets (without OS) in CMake
set(CMAKE_SYSTEM_NAME Generic)

# Fully featured RISC-V core with vector extension
set(CMAKE_SYSTEM_PROCESSOR rv32mafdcv)

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
