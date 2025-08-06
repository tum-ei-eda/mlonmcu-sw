PROJECT(embench_dsp)

SET(EMBENCH_DSP_DIR
    ""
    CACHE PATH "embench source directory"
)

IF(NOT EMBENCH_DSP_DIR)
    MESSAGE(FATAL_ERROR "Undefined: EMBENCH_DSP_DIR")
ENDIF()

SET(EMBENCH_DSP_BENCHMARK
    ""
    CACHE STRING "Specify which benchmark to run."
)
# SET_PROPERTY(CACHE EMBENCH_BENCHMARK PROPERTY STRINGS TODO)

SET(EMBENCH_DSP_NO_SNR_CHECK
    OFF
    CACHE STRING "Skip checks."
)

IF(NOT EMBENCH_DSP_BENCHMARK)
    MESSAGE(FATAL_ERROR "Undefined: EMBENCH_DSP_BENCHMARK")
ENDIF()

SET(BENCH_DIR ${EMBENCH_DSP_DIR}/src/${EMBENCH_DSP_BENCHMARK})
FILE(GLOB BENCH_SRCS ${BENCH_DIR}/*.c)

SET(EMBENCH_DSP_LIB_DIR ${EMBENCH_DSP_DIR}/lib)
SET(EMBENCH_DSP_LIB_SRC ${EMBENCH_DSP_LIB_DIR}/src)
SET(EMBENCH_DSP_LIB_INC ${EMBENCH_DSP_LIB_DIR}/include)

SET(EMBENCH_DSP_LIB_SRCS
    ${EMBENCH_DSP_LIB_SRC}/BasicMathFunctions/arm_mult_f32.c
    ${EMBENCH_DSP_LIB_SRC}/BasicMathFunctions/arm_scale_f32.c
    ${EMBENCH_DSP_LIB_SRC}/CommonTables/arm_common_tables.c
    ${EMBENCH_DSP_LIB_SRC}/CommonTables/arm_const_structs.c
    ${EMBENCH_DSP_LIB_SRC}/ComplexMathFunctions/arm_cmplx_mult_cmplx_f32.c
    ${EMBENCH_DSP_LIB_SRC}/FilteringFunctions/arm_biquad_cascade_df2T_f32.c
    ${EMBENCH_DSP_LIB_SRC}/FilteringFunctions/arm_biquad_cascade_df2T_init_f32.c
    ${EMBENCH_DSP_LIB_SRC}/FilteringFunctions/arm_fir_f32.c
    ${EMBENCH_DSP_LIB_SRC}/FilteringFunctions/arm_fir_init_f32.c
    ${EMBENCH_DSP_LIB_SRC}/FilteringFunctions/arm_lms_f32.c
    ${EMBENCH_DSP_LIB_SRC}/FilteringFunctions/arm_lms_init_f32.c
    ${EMBENCH_DSP_LIB_SRC}/TransformFunctions/arm_bitreversal2.c
    ${EMBENCH_DSP_LIB_SRC}/TransformFunctions/arm_cfft_f32.c
    ${EMBENCH_DSP_LIB_SRC}/TransformFunctions/arm_cfft_init_f32.c
    ${EMBENCH_DSP_LIB_SRC}/TransformFunctions/arm_cfft_radix8_f32.c
    ${EMBENCH_DSP_LIB_SRC}/TransformFunctions/arm_dct4_f32.c
    ${EMBENCH_DSP_LIB_SRC}/TransformFunctions/arm_rfft_fast_f32.c
    ${EMBENCH_DSP_LIB_SRC}/TransformFunctions/arm_rfft_fast_init_f32.c
)


COMMON_ADD_LIBRARY(${PROJECT_NAME} STATIC embench_dsp.c boardsupport.c ${EMBENCH_DSP_DIR}/support/snr.c ${BENCH_SRCS} ${EMBENCH_DSP_LIB_SRCS})
TARGET_INCLUDE_DIRECTORIES(${PROJECT_NAME} PUBLIC . ${BENCH_DIR} ${EMBENCH_DSP_DIR}/support ${EMBENCH_DSP_LIB_INC})
TARGET_LINK_LIBRARIES(${PROJECT_NAME} PUBLIC m support)

IF(EMBENCH_DSP_NO_SNR_CHECK)
    TARGET_COMPILE_DEFINITIONS(${PROJECT_NAME} PUBLIC NO_SNR_CHECK)
ENDIF()

IF(${GLOBAL_ISEL})
target_compile_options(${PROJECT_NAME} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:C>:-mllvm -global-isel=1>")
target_compile_options(${PROJECT_NAME} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:CXX>:-mllvm -global-isel=1>")
SET(GLOBAL_ISEL_ABORT 2)
target_compile_options(${PROJECT_NAME} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:C>:-mllvm -global-isel-abort=${GLOBAL_ISEL_ABORT}>")
target_compile_options(${PROJECT_NAME} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:CXX>:-mllvm -global-isel-abort=${GLOBAL_ISEL_ABORT}>")
ENDIF()
