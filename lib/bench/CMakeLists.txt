PROJECT(bench)

COMMON_ADD_LIBRARY(${PROJECT_NAME} STATIC bench.c)
TARGET_INCLUDE_DIRECTORIES(${PROJECT_NAME} PRIVATE .)
TARGET_LINK_LIBRARIES(${PROJECT_NAME} PRIVATE target_support support)

# RV32 LLVM22 RegBankSelect asserts for the i64 accounting in this file even
# with GISel fallback enabled. Keep the workload on the requested selector.
OPTION(GLOBAL_ISEL_BENCH_DAG "Use DAG only for bench.c when GISel is enabled" ON)
IF(GLOBAL_ISEL AND GLOBAL_ISEL_BENCH_DAG)
 SET_PROPERTY(SOURCE bench.c APPEND PROPERTY COMPILE_OPTIONS "-mllvm" "-global-isel=0")
 MESSAGE(STATUS "GISel exception: lib/bench/bench.c uses SelectionDAG")
ENDIF()
