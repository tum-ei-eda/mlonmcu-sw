SET(CMAKE_CXX_COMPILER_WORKS 1)
SET(CMAKE_C_COMPILER_WORKS 1)

# Contains toolchain configurations and settings for using LLVM/Clang
SET(TC_VARS
    RISCV_ELF_GCC_PREFIX
    RISCV_ELF_GCC_BASENAME
    RISCV_ARCH
    RISCV_ABI
    RISCV_ATTR
    LLVM_DIR
    FEATURE_EXTRA_C_FLAGS
    FEATURE_EXTRA_CXX_FLAGS
    FEATURE_EXTRA_ASM_FLAGS
    CMAKE_C_COMPILER
    CMAKE_CXX_COMPILER
    CMAKE_ASM_COMPILER
    CMAKE_OBJCOPY
    CMAKE_OBJDUMP
    FUSE_LD
)

ADD_DEFINITIONS(-D__riscv__)

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
SET(RISCV_ATTR
    "+m,+a,+c,+f,+d"
    CACHE STRING "mabi argument to the compiler"
)
SET(FUSE_LD
    "lld"
    CACHE STRING "fuse-ld value"
)
SET(GLOBAL_ISEL
    OFF
    CACHE BOOL "global-isel value"
)
SET(EXTEND_ATTRS
    OFF
    CACHE BOOL "Convert -mattr to -Xclang -X -target-feature args"
)
SET(OBJDUMP_EXTRA_ARGS "--mattr=${RISCV_ATTR}")
STRING(SUBSTRING ${RISCV_ARCH} 2 2 XLEN)
SET(TC_PREFIX "${RISCV_ELF_GCC_PREFIX}/bin/${RISCV_ELF_GCC_BASENAME}-")

SET(LLVM_VERSION_MAJOR 14)  # TODO: should not be hardcoded

IF(LLVM_VERSION_MAJOR LESS 13)
    MESSAGE(FATAL_ERROR "LLVM version 13 or higher is required")
ENDIF()


IF(RISCV_VEXT)
    # IF(NOT DEFINED RISCV_RVV_MAJOR OR NOT DEFINED RISCV_RVV_MINOR)
    #     MESSAGE(FATAL_ERROR "RISCV_VEXT requires RISCV_RVV_MAJOR and RISCV_RVV_MINOR")
    # ENDIF()
    # SET(RISCV_ARCH_FULL "${RISCV_ARCH}${RISCV_RVV_MAJOR}p${RISCV_RVV_MINOR}")
    SET(RISCV_ARCH_FULL "${RISCV_ARCH}")
    IF(LLVM_VERSION_MAJOR EQUAL 13)
        SET(CMAKE_C_FLAGS
            "${CMAKE_C_FLAGS} -menable-experimental-extensions -mno-relax"
        )
        SET(CMAKE_CXX_FLAGS
            "${CMAKE_CXX_FLAGS} -menable-experimental-extensions -mno-relax"
        )
        SET(CMAKE_ASM_FLAGS
            "${CMAKE_ASM_FLAGS} -menable-experimental-extensions -mno-relax"
        )
    ENDIF()
ELSE()
    SET(RISCV_ARCH_FULL ${RISCV_ARCH})
ENDIF()

# Workarounds for unsupported march strings
STRING(REPLACE "_zicsr" "" RISCV_ARCH_FULL ${RISCV_ARCH_FULL})
STRING(REPLACE "_zifencei" "" RISCV_ARCH_FULL ${RISCV_ARCH_FULL})

SET(TC_C_FLAGS "")
SET(TC_CXX_FLAGS "")
SET(TC_ASM_FLAGS "")
SET(TC_LD_FLAGS "")
LIST(APPEND TC_C_FLAGS "-march=${RISCV_ARCH}")
LIST(APPEND TC_C_FLAGS "-mabi=${RISCV_ABI}")
LIST(APPEND TC_C_FLAGS "--target=riscv${XLEN}")
LIST(APPEND TC_C_FLAGS "--gcc-toolchain=${RISCV_ELF_GCC_PREFIX}")
LIST(APPEND TC_C_FLAGS "--sysroot=${RISCV_ELF_GCC_PREFIX}/${RISCV_ELF_GCC_BASENAME}")
LIST(APPEND TC_CXX_FLAGS "-march=${RISCV_ARCH}")
LIST(APPEND TC_CXX_FLAGS "-mabi=${RISCV_ABI}")
LIST(APPEND TC_CXX_FLAGS "--target=riscv${XLEN}")
LIST(APPEND TC_CXX_FLAGS "--gcc-toolchain=${RISCV_ELF_GCC_PREFIX}")
LIST(APPEND TC_CXX_FLAGS "--sysroot=${RISCV_ELF_GCC_PREFIX}/${RISCV_ELF_GCC_BASENAME}")
LIST(APPEND TC_ASM_FLAGS "-march=${RISCV_ARCH}")
LIST(APPEND TC_ASM_FLAGS "-mabi=${RISCV_ABI}")
LIST(APPEND TC_ASM_FLAGS "--target=riscv${XLEN}")
LIST(APPEND TC_ASM_FLAGS "--gcc-toolchain=${RISCV_ELF_GCC_PREFIX}")
LIST(APPEND TC_ASM_FLAGS "--sysroot=${RISCV_ELF_GCC_PREFIX}/${RISCV_ELF_GCC_BASENAME}")
LIST(APPEND TC_LD_FLAGS "-march=${RISCV_ARCH}")
LIST(APPEND TC_LD_FLAGS "-mabi=${RISCV_ABI}")
LIST(APPEND TC_LD_FLAGS "--target=riscv${XLEN}")
LIST(APPEND TC_LD_FLAGS "--gcc-toolchain=${RISCV_ELF_GCC_PREFIX}")
LIST(APPEND TC_LD_FLAGS "--sysroot=${RISCV_ELF_GCC_PREFIX}/${RISCV_ELF_GCC_BASENAME}")

if(EXTEND_ATTRS)
    string(REPLACE "," ";" RISCV_ATTR_LIST ${RISCV_ATTR})
    foreach(X IN ITEMS ${RISCV_ATTR_LIST})
        LIST(APPEND TC_C_FLAGS "-Xclang -target-feature -Xclang ${X}")
        LIST(APPEND TC_CXX_FLAGS "-Xclang -target-feature -Xclang ${X}")
        LIST(APPEND TC_ASM_FLAGS "-Xclang -target-feature -Xclang ${X}")
    endforeach()
endif()

IF(NOT "${FUSE_LD}" STREQUAL "" AND NOT "${FUSE_LD}" STREQUAL "none")
    LIST(APPEND TC_LD_FLAGS "-fuse-ld=${FUSE_LD}")
ENDIF()
# IF(${GLOBAL_ISEL})
#     LIST(APPEND TC_C_FLAGS "-mllvm -global-isel=1")
#     LIST(APPEND TC_CXX_FLAGS "-mllvm -global-isel=1")
# ENDIF()

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
