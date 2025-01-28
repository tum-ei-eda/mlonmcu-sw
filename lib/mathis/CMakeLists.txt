PROJECT(mathis)

SET(MATHIS_TEST
    ""
    CACHE STRING "Specify which test to run."
)
# SET_PROPERTY(CACHE MATHIS_TEST PROPERTY STRINGS TODO)

IF(NOT MATHIS_TEST)
    MESSAGE(FATAL_ERROR "Undefined: MATHIS_TEST")
ENDIF()

SET(MATHIS_SIZE
    "1024"
    CACHE STRING "Specify size of arrays."
)
SET(MATHIS_N
    "1024"
    CACHE STRING "Specify number of elements."
)
SET(MATHIS_NARGS
    "1"
    CACHE STRING "Specify number of args (has to match selected function)."
)
SET(MATHIS_ELEM_SZIE
    "8"
    CACHE STRING "Specify number of bits (has to match selected function)."
)

FILE(GLOB BENCH_SRCS test.c)

COMMON_ADD_LIBRARY(${PROJECT_NAME} STATIC mathis.c ${BENCH_SRCS})
TARGET_INCLUDE_DIRECTORIES(${PROJECT_NAME} PUBLIC .)
# TARGET_LINK_LIBRARIES(${PROJECT_NAME} PUBLIC m)
TARGET_COMPILE_DEFINITIONS(${PROJECT_NAME} PUBLIC -DSIZE=${MATHIS_SIZE} -DNARGS=${MATHIS_NARGS} -DFUNCTION=${MATHIS_TEST} -DELEM_SIZE=${MATHIS_ELEM_SIZE} -DN=${MATHIS_N})

IF(${GLOBAL_ISEL})
target_compile_options(${PROJECT_NAME} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:C>:-mllvm -global-isel=1>")
target_compile_options(${PROJECT_NAME} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:CXX>:-mllvm -global-isel=1>")
SET(GLOBAL_ISEL_ABORT 2)
target_compile_options(${PROJECT_NAME} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:C>:-mllvm -global-isel-abort=${GLOBAL_ISEL_ABORT}>")
target_compile_options(${PROJECT_NAME} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:CXX>:-mllvm -global-isel-abort=${GLOBAL_ISEL_ABORT}>")
ENDIF()
