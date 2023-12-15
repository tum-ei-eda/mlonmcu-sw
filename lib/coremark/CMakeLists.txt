PROJECT(coremark)

SET(COREMARK_ITERATIONS
    10
    CACHE STRING "How many iterations to run."  # Cmake does not support int type?
)

# TODO: subdirs!
COMMON_ADD_LIBRARY(${PROJECT_NAME} STATIC
    core_list_join.c
    core_main.c
    core_matrix.c
    core_portme.c
    core_state.c
    core_util.c
)

TARGET_INCLUDE_DIRECTORIES(${PROJECT_NAME} PUBLIC . ../targets/)

TARGET_COMPILE_DEFINITIONS(${PROJECT_NAME} PRIVATE
    -DITERATIONS=${COREMARK_ITERATIONS}
    -DFLAGS_STR="testing mlonmcu"
    -DPERFORMANCE_RUN
    -DHAS_STDIO
)

TARGET_LINK_LIBRARIES(${PROJECT_NAME} PRIVATE target_support support)
