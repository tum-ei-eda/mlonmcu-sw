SET(TC_VARS
    RISCV_ELF_GCC_PREFIX
    RISCV_ELF_GCC_BASENAME
    RISCV_ARCH
    RISCV_ABI
    FEATURE_EXTRA_C_FLAGS
    FEATURE_EXTRA_CXX_FLAGS
    FEATURE_EXTRA_ASM_FLAGS
    EXE_EXT
)

SET(RISCV_ELF_GCC_PREFIX
    ""
    CACHE PATH "install location for riscv-gcc toolchain"
)
SET(RISCV_ELF_GCC_BASENAME
    "riscv64-unknown-elf"
    CACHE STRING "base name of the toolchain executables"
)
SET(RISCV_ARCH
    "rv32gc"
    CACHE STRING "march argument to the compiler"
)
SET(RISCV_ABI
    "ilp32d"
    CACHE STRING "mabi argument to the compiler"
)
SET(TC_PREFIX "${RISCV_ELF_GCC_PREFIX}/bin/${RISCV_ELF_GCC_BASENAME}-")

if(NOT (EXISTS "${TC_PREFIX}gcc${EXE_EXT}"))
   MESSAGE(FATAL_ERROR, "${TC_PREFIX}gcc${EXE_EXT} NOT FOUND")
endif()

SET(CMAKE_C_COMPILER ${TC_PREFIX}gcc${EXE_EXT})
SET(CMAKE_CXX_COMPILER ${TC_PREFIX}g++${EXE_EXT})
SET(CMAKE_ASM_COMPILER ${TC_PREFIX}gcc${EXE_EXT})
SET(CMAKE_LINKER ${TC_PREFIX}ld${EXE_EXT})
SET(CMAKE_OBJCOPY ${TC_PREFIX}objcopy${EXE_EXT})
SET(CMAKE_AR ${TC_PREFIX}ar${EXE_EXT})
SET(CMAKE_RANLIB ${TC_PREFIX}ranlib${EXE_EXT})

SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -march=${RISCV_ARCH} -mabi=${RISCV_ABI}")

ADD_DEFINITIONS(-march=${RISCV_ARCH})
ADD_DEFINITIONS(-mabi=${RISCV_ABI})

SET(CMAKE_C_FLAGS
    "${CMAKE_C_FLAGS} ${FEATURE_EXTRA_C_FLAGS}"
)
SET(CMAKE_CXX_FLAGS
    "${CMAKE_CXX_FLAGS} ${FEATURE_EXTRA_CXX_FLAGS}"
)
SET(CMAKE_ASM_FLAGS
    "${CMAKE_ASM_FLAGS} ${FEATURE_EXTRA_ASM_FLAGS}"
)
IF(RISCV_VEXT)
    IF(RISCV_VLEN)
        # SET(FEATURE_EXTRA_CXX_FLAGS "${FEATURE_EXTRA_CXX_FLAGS} \
        #     -mriscv-vector-bits=${RISCV_VLEN} \
        # ")
    ENDIF()
ENDIF()

separate_arguments(C_ARGS UNIX_COMMAND ${FEATURE_EXTRA_C_FLAGS})
add_compile_options("$<$<COMPILE_LANGUAGE:C>:${C_ARGS}>")
separate_arguments(CXX_ARGS UNIX_COMMAND ${FEATURE_EXTRA_CXX_FLAGS})
add_compile_options("$<$<COMPILE_LANGUAGE:CXX>:${CXX_ARGS}>")
separate_arguments(ASM_ARGS UNIX_COMMAND ${FEATURE_EXTRA_ASM_FLAGS})
add_compile_options("$<$<COMPILE_LANGUAGE:ASM>:${ASM_ARGS}>")
