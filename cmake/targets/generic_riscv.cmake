# The Generic system name is used for bare-metal targets (without OS) in CMake
SET(CMAKE_SYSTEM_NAME Generic)

# Fully featured RISC-V core with vector extension
SET(CMAKE_SYSTEM_PROCESSOR rv32mafdcv)

# The linker argument setting below will break the cmake test program on 64-bit, so disable test program linking for
# now.
SET(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

ADD_DEFINITIONS(-D__riscv__)

IF(RISCV_VEXT)
    ADD_DEFINITIONS(-DUSE_VEXT)
ENDIF()
