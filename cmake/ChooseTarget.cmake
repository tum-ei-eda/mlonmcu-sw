# New target architectures and systems should be added here Make sure to define the CMAKE_TOOLCHAIN_FILE for
# cross-compilation

# Default implementation of the macro points to the original ADD_LIBRARY function
MACRO(COMMON_ADD_LIBRARY TARGET_NAME)
    ADD_LIBRARY(${TARGET_NAME} ${ARGN})
ENDMACRO()

MACRO(COMMON_ADD_EXECUTABLE TARGET_NAME)
    ADD_EXECUTABLE(${TARGET_NAME} ${ARGN})
ENDMACRO()

SET(TARGET_SYSTEM_FILE "auto" CACHE STRING "Target specific cmake file.")
SET(TOOLCHAIN_FILE "auto" CACHE STRING "Which target-specific toolchain file should be used.")

IF(TARGET_SYSTEM)
    IF("${TARGET_SYSTEM_FILE}" STREQUAL "auto")
        INCLUDE(targets/${TARGET_SYSTEM})
    ELSE()
        IF(EXISTS ${TARGET_SYSTEM_FILE})
            INCLUDE(${TARGET_SYSTEM_FILE})
        ELSE()
            MESSAGE(FATAL_ERROR "The target system file '${TARGET_SYSTEM_FILE}' does not exist")
        ENDIF()
    ENDIF()
    IF(TOOLCHAIN)
        IF("${TOOLCHAIN_FILE}" STREQUAL "auto")
            SET(TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/cmake/toolchains/${TOOLCHAIN}_${TARGET_SYSTEM}.cmake")
        ENDIF()
        IF(EXISTS ${TOOLCHAIN_FILE})
            INCLUDE(${TOOLCHAIN_FILE})
        ELSE()
            MESSAGE(FATAL_ERROR "The TOOLCHAIN file '${TOOLCHAIN_FILE}' does not exist")
        ENDIF()
    ENDIF()
    STRING(TOUPPER ${TARGET_SYSTEM} TARGET_SYSTEM_UPPER)
    ADD_DEFINITIONS(-DMLONMCU_TARGET_${TARGET_SYSTEM_UPPER})
ENDIF()

# set(CMAKE_EXECUTABLE_SUFFIX_C .elf)
