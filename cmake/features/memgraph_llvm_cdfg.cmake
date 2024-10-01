SET(MEMGRAPH_LLVM_CDFG OFF CACHE BOOL "Enable LLVMs -cdfg-enable=1 (custom)")
SET(MEMGRAPH_LLVM_CDFG_SESSION "" CACHE STRING "Set LLVMs -cdfg-memgraph-session=?")
SET(MEMGRAPH_LLVM_CDFG_STAGE_MASK 32 CACHE STRING "Set LLVMs -cdfg-stage-mask=?")
IF(MEMGRAPH_LLVM_CDFG)
    set(CMAKE_C_COMPILER_WORKS TRUE)
    set(CMAKE_CXX_COMPILER_WORKS TRUE)
    IF(NOT ${TOOLCHAIN} STREQUAL "llvm")
        MESSAGE(FATAL_ERROR "memgraph_llvm_cdfg feature needs llvm toolchain")
    ENDIF()
    LIST(APPEND CDFG_FLAGS "-mllvm -cdfg-enable=1")
    IF(DEFINED MEMGRAPH_LLVM_CDFG_SESSION AND NOT MEMGRAPH_LLVM_CDFG_SESSION STREQUAL "")
        LIST(APPEND CDFG_FLAGS "-mllvm -cdfg-memgraph-session=${MEMGRAPH_LLVM_CDFG_SESSION}")
    ENDIF()
    IF(DEFINED MEMGRAPH_LLVM_CDFG_STAGE_MASK)
        LIST(APPEND CDFG_FLAGS "-mllvm -cdfg-stage-mask=${MEMGRAPH_LLVM_CDFG_STAGE_MASK}")
    ENDIF()
    LIST(APPEND FEATURE_EXTRA_C_FLAGS ${CDFG_FLAGS})
    LIST(APPEND FEATURE_EXTRA_CXX_FLAGS ${CDFG_FLAGS})
ENDIF()
