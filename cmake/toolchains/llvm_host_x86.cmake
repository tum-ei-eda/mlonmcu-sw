# Contains toolchain configurations and settings for using LLVM/Clang
SET(TC_VARS
    LLVM_DIR
    FEATURE_EXTRA_C_FLAGS
    FEATURE_EXTRA_CXX_FLAGS
    FEATURE_EXTRA_ASM_FLAGS
    CMAKE_C_COMPILER
    CMAKE_CXX_COMPILER
    CMAKE_ASM_COMPILER
)

INCLUDE(LookupClang OPTIONAL RESULT_VARIABLE LOOKUP_CLANG_MODULE)

IF(LOOKUP_CLANG_MODULE)
    SET(CMAKE_C_COMPILER ${CLANG_EXECUTABLE})
    SET(CMAKE_CXX_COMPILER ${CLANGPP_EXECUTABLE})
    SET(CMAKE_ASM_COMPILER ${CLANG_EXECUTABLE})
ENDIF()

# Lets stick to standard .elf file ending for now set(CMAKE_EXECUTABLE_SUFFIX_C .elf)

SET(LLVM_VERSION_MAJOR 14)  # TODO: should not be hardcoded

IF(LLVM_VERSION_MAJOR LESS 13)
    MESSAGE(FATAL_ERROR "LLVM version 13 or higher is required")
ENDIF()
# set(CMAKE_C_LINKER lld-13) # TODO(fabianpedd): doesnt work, need to use -fuse-ld=lld-13 instead

foreach(X IN ITEMS ${EXTRA_CMAKE_C_FLAGS} ${FEATURE_EXTRA_C_FLAGS})
    add_compile_options("SHELL:$<$<COMPILE_LANGUAGE:C>:${X}>")
endforeach()
foreach(X IN ITEMS ${EXTRA_CMAKE_CXX_FLAGS} ${FEATURE_EXTRA_CXX_FLAGS})
    add_compile_options("SHELL:$<$<COMPILE_LANGUAGE:CXX>:${X}>")
endforeach()
foreach(X IN ITEMS ${EXTRA_CMAKE_ASM_FLAGS} ${FEATURE_EXTRA_ASM_FLAGS})
    add_compile_options("SHELL:$<$<COMPILE_LANGUAGE:ASM>:${X}>")
endforeach()
