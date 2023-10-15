# New target architectures and systems should be added here Make sure to define the CMAKE_TOOLCHAIN_FILE for
# cross-compilation

# Default implementation of the macro points to the original ADD_LIBRARY function
MACRO(COMMON_ADD_LIBRARY TARGET_NAME)
    ADD_LIBRARY(${TARGET_NAME} ${ARGN})
ENDMACRO()

MACRO(COMMON_ADD_EXECUTABLE TARGET_NAME)
    ADD_EXECUTABLE(${TARGET_NAME} ${ARGN})
ENDMACRO()

SET(TOOLCHAIN_FILE "")
IF(TARGET_SYSTEM)
    INCLUDE(targets/${TARGET_SYSTEM})
    IF(TOOLCHAIN)
        SET(TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/cmake/toolchains/${TOOLCHAIN}_${TARGET_SYSTEM}.cmake")
        IF(EXISTS ${TOOLCHAIN_FILE})
            INCLUDE(${TOOLCHAIN_FILE})
        ELSE()
            MESSAGE(FATAL_ERROR "The TOOLCHAIN file for the TOOLCHAIN '${TOOLCHAIN}' does not exist")
        ENDIF()
    ENDIF()
    string(TOUPPER ${VARNAME} TARGET_SYSTEM_UPPER)
    ADD_DEFINITIONS(MLONMCU_TARGET_${TARGET_SYSTEM_UPPER})
ENDIF()

# set(CMAKE_EXECUTABLE_SUFFIX_C .elf)
