PROJECT(target_support)

SET(TARGET_LIB_SOURCE ${TARGET_SYSTEM}.c)
IF(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${TARGET_LIB_SOURCE})
    SET(TARGET_LIB_SOURCE default.c)
ENDIF()

COMMON_ADD_LIBRARY(${PROJECT_NAME} STATIC ${TARGET_LIB_SOURCE} target.c)
TARGET_INCLUDE_DIRECTORIES(${PROJECT_NAME} PUBLIC .)
