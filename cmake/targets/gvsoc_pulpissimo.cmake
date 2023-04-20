SET(CMAKE_SYSTEM_NAME Generic)
SET(CMAKE_SYSTEM_PROCESSOR Pulp)

INCLUDE(targets/gvsoc/PulpissimoTarget)
MACRO(COMMON_ADD_LIBRARY TARGET_NAME)
    ADD_LIBRARY_GVSOC_PULPISSIMO(${TARGET_NAME} ${ARGN})
ENDMACRO()
MACRO(COMMON_ADD_EXECUTABLE TARGET_NAME)
    SET(ARGS "${ARGN}")
    SET(SRC_FILES ${ARGS})
    ADD_EXECUTABLE_GVSOC_PULPISSIMO(${TARGET_NAME} ${ARGN})
ENDMACRO()

IF(RISCV_VEXT)
    ADD_DEFINITIONS(-DUSE_VEXT)
ENDIF()
