# New target architectures and systems should be added here Make sure to define the CMAKE_TOOLCHAIN_FILE for
# cross-compilation

# Default implementation of the macro points to the original ADD_LIBRARY function
MACRO(COMMON_ADD_LIBRARY TARGET_NAME)
    ADD_LIBRARY(${TARGET_NAME} ${ARGN})
ENDMACRO()

MACRO(COMMON_ADD_EXECUTABLE TARGET_NAME)
    ADD_EXECUTABLE(${TARGET_NAME} ${ARGN})
ENDMACRO()

IF(TARGET_SYSTEM)
    INCLUDE(targets/${TARGET_SYSTEM})
    IF(TOOLCHAIN)
        INCLUDE(toolchains/${TOOLCHAIN}_${TARGET_SYSTEM})
    ENDIF()
ENDIF()

# set(CMAKE_EXECUTABLE_SUFFIX_C .elf)
