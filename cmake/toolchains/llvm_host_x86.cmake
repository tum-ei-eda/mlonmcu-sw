SET(TC_VARS
    LLVM_DIR
    FEATURE_EXTRA_C_FLAGS
    FEATURE_EXTRA_CXX_FLAGS
    FEATURE_EXTRA_ASM_FLAGS
)
# Contains toolchain configurations and settings for using LLVM/Clang

# Lets stick to standard .elf file ending for now set(CMAKE_EXECUTABLE_SUFFIX_C .elf)

INCLUDE(LookupClang)

SET(CMAKE_C_COMPILER ${CLANG_EXECUTABLE})
SET(CMAKE_CXX_COMPILER ${CLANG++_EXECUTABLE})
SET(CMAKE_ASM_COMPILER ${CLANG_EXECUTABLE})
# TODO: automatic lookup with find_program

SET(LLVM_VERSION_MAJOR 14)  # TODO: should not be hardcoded

IF(LLVM_VERSION_MAJOR LESS 13)
    MESSAGE(FATAL_ERROR "LLVM version 13 or higher is required")
ENDIF()
# set(CMAKE_C_LINKER lld-13) # TODO(fabianpedd): doesnt work, need to use -fuse-ld=lld-13 instead


SET(CMAKE_C_FLAGS
    "${CMAKE_C_FLAGS} ${FEATURE_EXTRA_C_FLAGS}"
)
SET(CMAKE_CXX_FLAGS
    "${CMAKE_CXX_FLAGS} ${FEATURE_EXTRA_CXX_FLAGS}"
)
SET(CMAKE_ASM_FLAGS
    "${CMAKE_ASM_FLAGS} ${FEATURE_EXTRA_ASM_FLAGS}"
)
