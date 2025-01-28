# TODO: reuse/update CMSIS-NN feature
SET(CMSIS_NN_DIR /work/git/CMSIS-NN/)  # TODO: expose
SET(CMSIS_PATH /work/git/mlonmcu/mlonmcu/workspace_default/deps/src/cmsis/)  # TODO: expose

ADD_LIBRARY(cmsis-nn STATIC)
ADD_SUBDIRECTORY(${CMSIS_NN_DIR}/Source cmsis_nn)
TARGET_INCLUDE_DIRECTORIES(cmsis-nn PUBLIC ${CMSIS_NN_DIR}/Include)

IF(${GLOBAL_ISEL})
target_compile_options(cmsis-nn PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:C>:-mllvm -global-isel=1>")
target_compile_options(cmsis-nn PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:CXX>:-mllvm -global-isel=1>")
SET(GLOBAL_ISEL_ABORT 2)
target_compile_options(cmsis-nn PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:C>:-mllvm -global-isel-abort=${GLOBAL_ISEL_ABORT}>")
target_compile_options(cmsis-nn PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:CXX>:-mllvm -global-isel-abort=${GLOBAL_ISEL_ABORT}>")
ENDIF()

PROJECT(cmsis_nn_bench)

SET(CMSIS_NN_BENCHMARK
    ""
    CACHE STRING "Specify which benchmark to run."
)
# SET_PROPERTY(CACHE EMBENCH_BENCHMARK PROPERTY STRINGS TODO)
SET(CMSIS_NN_SIZE
    "16"
    CACHE STRING "Specify size of arrays."
)
SET(CMSIS_NN_BATCH_SIZE
    "16"
    CACHE STRING "Specify size of batches."
)
SET(CMSIS_NN_NUMBER
    "10"
    CACHE STRING "Specify numbe of iterations."
)

IF(NOT CMSIS_NN_BENCHMARK)
    MESSAGE(FATAL_ERROR "Undefined: CMSIS_NN_BENCHMARK")
ENDIF()

FILE(GLOB BENCH_SRCS bench_${CMSIS_NN_BENCHMARK}.c)

COMMON_ADD_LIBRARY(${PROJECT_NAME} STATIC ${BENCH_SRCS})
TARGET_LINK_LIBRARIES(${PROJECT_NAME} PUBLIC m support)
TARGET_COMPILE_DEFINITIONS(${PROJECT_NAME} PUBLIC NUMBER=${CMSIS_NN_NUMBER} SIZE=${CMSIS_NN_SIZE} BATCH=${CMSIS_NN_BATCH_SIZE} __GNUC_PYTHON__)  # TODO: expose


TARGET_INCLUDE_DIRECTORIES(${PROJECT_NAME} PUBLIC ${CMSIS_NN_DIR}/Include)
TARGET_LINK_LIBRARIES(${PROJECT_NAME} PUBLIC cmsis-nn)

IF(${GLOBAL_ISEL})
target_compile_options(${PROJECT_NAME} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:C>:-mllvm -global-isel=1>")
target_compile_options(${PROJECT_NAME} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:CXX>:-mllvm -global-isel=1>")
SET(GLOBAL_ISEL_ABORT 2)
target_compile_options(${PROJECT_NAME} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:C>:-mllvm -global-isel-abort=${GLOBAL_ISEL_ABORT}>")
target_compile_options(${PROJECT_NAME} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:CXX>:-mllvm -global-isel-abort=${GLOBAL_ISEL_ABORT}>")
ENDIF()
