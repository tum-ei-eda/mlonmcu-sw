SET(RISCV_ELF_GCC_PREFIX
    ""
    CACHE PATH "install location for riscv-gcc toolchain"
)
SET(RISCV_ELF_GCC_BASENAME
    "riscv64-unknown-elf"
    CACHE STRING "base name of the toolchain executables"
)
SET(RISCV_ARCH
    "rv32imc"
    CACHE STRING "march argument to the compiler"
)
# set(RISCV_ARCH "rv32gcv" CACHE STRING "march argument to the compiler")
SET(RISCV_ABI
    "ilp32"
    CACHE STRING "mabi argument to the compiler"
)
SET(TC_PREFIX "${RISCV_ELF_GCC_PREFIX}/bin/${RISCV_ELF_GCC_BASENAME}-")

# The linker argument setting below will break the cmake test program on 64-bit, so disable test program linking for
# now.

SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -march=${RISCV_ARCH} -mabi=${RISCV_ABI}")

ADD_DEFINITIONS(-D__riscv__)
SET(CMAKE_C_COMPILER ${TC_PREFIX}gcc${EXE_EXT})
SET(CMAKE_CXX_COMPILER ${TC_PREFIX}g++${EXE_EXT})
SET(CMAKE_ASM_COMPILER ${TC_PREFIX}gcc${EXE_EXT})
SET(CMAKE_LINKER ${TC_PREFIX}ld${EXE_EXT})
SET(CMAKE_OBJCOPY ${TC_PREFIX}objcopy${EXE_EXT})
SET(CMAKE_AR ${TC_PREFIX}ar${EXE_EXT})
SET(CMAKE_RANLIB ${TC_PREFIX}ranlib${EXE_EXT})

SET(TC_C_FLAGS "")
SET(TC_CXX_FLAGS "")
SET(TC_ASM_FLAGS "")
SET(TC_LD_FLAGS "")
LIST(APPEND TC_C_FLAGS "-march=${RISCV_ARCH}")
LIST(APPEND TC_C_FLAGS "-mabi=${RISCV_ABI}")
LIST(APPEND TC_CXX_FLAGS "-march=${RISCV_ARCH}")
LIST(APPEND TC_CXX_FLAGS "-mabi=${RISCV_ABI}")
LIST(APPEND TC_ASM_FLAGS "-march=${RISCV_ARCH}")
LIST(APPEND TC_ASM_FLAGS "-mabi=${RISCV_ABI}")
LIST(APPEND TC_LD_FLAGS "-march=${RISCV_ARCH}")
LIST(APPEND TC_LD_FLAGS "-mabi=${RISCV_ABI}")

foreach(X IN ITEMS ${TC_C_FLAGS} ${EXTRA_CMAKE_C_FLAGS} ${FEATURE_EXTRA_C_FLAGS})
    add_compile_options("SHELL:$<$<COMPILE_LANGUAGE:C>:${X}>")
endforeach()
foreach(X IN ITEMS ${TC_CXX_FLAGS} ${EXTRA_CMAKE_CXX_FLAGS} ${FEATURE_EXTRA_CXX_FLAGS})
    add_compile_options("SHELL:$<$<COMPILE_LANGUAGE:CXX>:${X}>")
endforeach()
foreach(X IN ITEMS ${TC_ASM_FLAGS} ${EXTRA_CMAKE_ASM_FLAGS} ${FEATURE_EXTRA_ASM_FLAGS})
    add_compile_options("SHELL:$<$<COMPILE_LANGUAGE:ASM>:${X}>")
endforeach()
foreach(X IN ITEMS ${TC_LD_FLAGS} ${EXTRA_CMAKE_LD_FLAGS} ${FEATURE_EXTRA_LD_FLAGS})
    add_link_options("SHELL:${X}")
endforeach()
