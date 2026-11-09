SET(CMAKE_C_COMPILER_TARGET riscv32-unknown-elf)
SET(CMAKE_CXX_COMPILER_TARGET riscv32-unknown-elf)
SET(CMAKE_ASM_COMPILER_TARGET riscv32-unknown-elf)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/llvm_generic_riscv.cmake)
