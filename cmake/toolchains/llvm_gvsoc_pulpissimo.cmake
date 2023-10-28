# Contains toolchain configurations and settings for using LLVM/Clang
SET(TC_VARS
    RISCV_ELF_GCC_PREFIX
    RISCV_ELF_GCC_BASENAME
    RISCV_ARCH
    RISCV_ABI
    LLVM_DIR
    FEATURE_EXTRA_C_FLAGS
    FEATURE_EXTRA_CXX_FLAGS
    FEATURE_EXTRA_ASM_FLAGS
    CMAKE_C_COMPILER
    CMAKE_CXX_COMPILER
    CMAKE_ASM_COMPILER
    CMAKE_OBJCOPY
    CMAKE_OBJDUMP
)

INCLUDE(LookupClang OPTIONAL RESULT_VARIABLE LOOKUP_CLANG_MODULE)

IF(LOOKUP_CLANG_MODULE)
    SET(CMAKE_C_COMPILER ${CLANG_EXECUTABLE})
    SET(CMAKE_CXX_COMPILER ${CLANGPP_EXECUTABLE})
    SET(CMAKE_ASM_COMPILER ${CLANG_EXECUTABLE})
    SET(CMAKE_OBJCOPY ${LLVM_OBJCOPY_EXECUTABLE})
    SET(CMAKE_OBJDUMP ${LLVM_OBJDUMP_EXECUTABLE})
ENDIF()

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
STRING(SUBSTRING ${RISCV_ARCH} 2 2 XLEN)

# set(CMAKE_C_LINKER lld-13) # TODO(fabianpedd): doesnt work, need to use -fuse-ld=lld-13 instead

# RV32GC processor
SET(CMAKE_SYSTEM_PROCESSOR Pulp)

# The linker argument setting below will break the cmake test program on 64-bit, so disable test program linking for
# now.
SET(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

# the following is transfered from PULP-FreeRTOS repository
# https://github.com/pulp-platform/pulp-freertos/blob/master/default_flags.mk#L110-L126
# Builtin mandatory flags. Need to be simply expanded variables for appends in
# other cmake files to work correctly
SET(CV_CFLAGS "\
--target=riscv${XLEN} \
--gcc-toolchain=${RISCV_ELF_GCC_PREFIX} --sysroot=${RISCV_ELF_GCC_PREFIX}/${RISCV_ELF_GCC_BASENAME} \
-msmall-data-limit=8 -mno-save-restore \
-fsigned-char -ffunction-sections -fdata-sections \
-Wall -Wextra -Wshadow -Wformat=2 -Wundef -Wsign-conversion -Wno-unused-parameter") # -std=gnu11 \

SET(CV_ASFLAGS "\
--target=riscv${XLEN} \
--gcc-toolchain=${RISCV_ELF_GCC_PREFIX} --sysroot=${RISCV_ELF_GCC_PREFIX}/${RISCV_ELF_GCC_BASENAME} \
-msmall-data-limit=8 -mno-save-restore \
-fsigned-char -ffunction-sections -fdata-sections \
-x assembler-with-cpp")

SET(CV_CPPFLAGS "--target=riscv${XLEN} --gcc-toolchain=${RISCV_ELF_GCC_PREFIX} --sysroot=${RISCV_ELF_GCC_PREFIX}/${RISCV_ELF_GCC_BASENAME}")

# note: linkerscript is included in target directory makefile.mk
SET(CV_LDFLAGS "\
-nostartfiles \
-Wl,--gc-sections \
-Wl,-Map,memory.map") # -Wl,--print-gc-sections

# LIST(APPEND CV_LDFLAGS " -Wstack-usage=1024")

# the following is transfered from PULP-FreeRTOS repository
# https://github.com/pulp-platform/pulp-freertos/blob/master/default_targets.mk#L77-L87
SET(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} ${CV_CFLAGS} ${CV_CPPFLAGS} -DSTDIO_FAKE=2 -DSTDIO_UART=1 -DSTDIO_NULL=0 -DCONFIG_STDIO=2 ")
SET(CMAKE_C_FLAGS  "${CMAKE_C_FLAGS} ${CV_CFLAGS} ${CV_CPPFLAGS} -DSTDIO_FAKE=2 -DSTDIO_UART=1 -DSTDIO_NULL=0 -DCONFIG_STDIO=2 ")
SET(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} ${CV_ASFLAGS} ${CV_CPPFLAGS} -DportasmHANDLE_INTERRUPT=vSystemIrqHandler ")
SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -DportasmHANDLE_INTERRUPT=vSystemIrqHandler ${CV_CFLAGS} ${CV_LDFLAGS} -fuse-ld=lld" )

foreach(X IN ITEMS ${EXTRA_CMAKE_C_FLAGS} ${FEATURE_EXTRA_C_FLAGS})
    add_compile_options("SHELL:$<$<COMPILE_LANGUAGE:C>:${X}>")
endforeach()
foreach(X IN ITEMS ${EXTRA_CMAKE_CXX_FLAGS} ${FEATURE_EXTRA_CXX_FLAGS})
    add_compile_options("SHELL:$<$<COMPILE_LANGUAGE:CXX>:${X}>")
endforeach()
foreach(X IN ITEMS ${EXTRA_CMAKE_ASM_FLAGS} ${FEATURE_EXTRA_ASM_FLAGS})
    add_compile_options("SHELL:$<$<COMPILE_LANGUAGE:ASM>:${X}>")
endforeach()
