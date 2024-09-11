IF(MEMGRAPH_LLVM_CDFG)
    set(CMAKE_C_COMPILER_WORKS TRUE)
    set(CMAKE_CXX_COMPILER_WORKS TRUE)

    IF(${TOOLCHAIN} STREQUAL "llvm")
        LIST(APPEND CDFG_FLAGS "-mllvm -cdfg-enable=1")
        IF(MEMGRAPH_LLVM_CDFG_SESSION)
            LIST(APPEND CDFG_FLAGS "-mllvm -cdfg-memgrapg_session=${MEMGRAPH_LLVM_CDFG_SESSION}")
        ENDIF()
        # TODO: move to new feature
        LIST(APPEND CDFG_FLAGS "-fbasic-block-sections=labels")
    ENDIF()

    LIST(APPEND FEATURE_EXTRA_C_FLAGS ${CDFG_FLAGS})
    LIST(APPEND FEATURE_EXTRA_CXX_FLAGS ${CDFG_FLAGS})
ENDIF()
