# New target architectures and systems should be added here Make sure to define the CMAKE_TOOLCHAIN_FILE for
# cross-compilation

# Default implementation of the macro points to the original ADD_LIBRARY function
MACRO(COMMON_ADD_LIBRARY TARGET_NAME)
    ADD_LIBRARY(${TARGET_NAME} ${ARGN})
ENDMACRO()

MACRO(COMMON_ADD_EXECUTABLE TARGET_NAME)
    ADD_EXECUTABLE(${TARGET_NAME} ${ARGN})
ENDMACRO()

IF(TARGET_SYSTEM STREQUAL "etiss_pulpino")
    SET(ETISS_DIR
        "/usr/local/research/projects/SystemDesign/tools/etiss/current"  # TODO: remove
        CACHE STRING "Directory of ETISS"
    )
    SET(PULPINO_TC_DIR ${ETISS_DIR}/examples/SW/riscv/cmake)
    SET(CMAKE_TOOLCHAIN_FILE "${PULPINO_TC_DIR}/pulpino_tumeda/toolchain.cmake")
    ADD_DEFINITIONS(-DPULPINO_NO_GPIO)
    SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PULPINO_TC_DIR}")
    IF(NOT PULPINO_ROM_START)
        SET(PULPINO_ROM_START 0x0)
    ENDIF()
    IF(NOT PULPINO_ROM_SIZE)
        SET(PULPINO_ROM_SIZE 0x100000)
    ENDIF()
    IF(NOT PULPINO_RAM_START)
        SET(PULPINO_RAM_START 0x100000)
    ENDIF()
    IF(NOT PULPINO_RAM_SIZE)
        SET(PULPINO_RAM_SIZE 0x200000)
    ENDIF()
    SET(PULPINO_MIN_STACK_SIZE 0x4000)
    SET(PULPINO_MIN_HEAP_SIZE 0x4000)
    SET(ETISS_LOGGER_ADDR 0xf0000000)

    INCLUDE(PulpinoTarget)
    MACRO(COMMON_ADD_LIBRARY TARGET_NAME)
        ADD_LIBRARY_PULPINO(${TARGET_NAME} ${ARGN})
    ENDMACRO()
    MACRO(COMMON_ADD_EXECUTABLE TARGET_NAME)
        SET(ARGS "${ARGN}")
        SET(SRC_FILES ${ARGS})
        ADD_EXECUTABLE_PULPINO(${TARGET_NAME} ${ARGN})
    ENDMACRO()
ELSEIF(TARGET_SYSTEM STREQUAL "host_x86")
    # Nothing to do...
ELSE()
    MESSAGE(FATAL_ERROR "The chosen value '${TARGET_SYSTEM}' for TARGET_SYSTEM is invalid.")
ENDIF()
