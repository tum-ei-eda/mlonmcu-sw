PROJECT(dhrystone)

SET(DHRYSTONE_ITERATIONS
    10
    CACHE STRING "How many iterations to run."  # Cmake does not support int type?
)

COMMON_ADD_LIBRARY(${PROJECT_NAME} STATIC
    dhrystone.c
    dhry_1.c
    dhry_2.c

)

TARGET_INCLUDE_DIRECTORIES(${PROJECT_NAME} PUBLIC . ../targets/)

TARGET_COMPILE_DEFINITIONS(${PROJECT_NAME} PRIVATE
    -DNUMBER_OF_RUNS=${DHRYSTONE_ITERATIONS}
    -DNO_INIT
    -DTIME
    -DUNTIME
)

TARGET_COMPILE_OPTIONS(${PROJECT_NAME} PRIVATE -Wno-implicit-int -Wno-implicit-function-declaration)

TARGET_LINK_LIBRARIES(${PROJECT_NAME} PRIVATE target_support support)
IF(${GLOBAL_ISEL})
target_compile_options(${PROJECT_NAME} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:C>:-mllvm -global-isel=1>")
target_compile_options(${PROJECT_NAME} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:CXX>:-mllvm -global-isel=1>")
ENDIF()
