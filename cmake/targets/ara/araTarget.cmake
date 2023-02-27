SET(ARA_COMMON_DIR ${CMAKE_CURRENT_LIST_DIR}/apps/common)

MACRO(ARA_SETTINGS_PRE)
    SET(ARA_INCLUDES
            ${ARA_COMMON_DIR}
    )

    SET(CMAKE_EXPORT_COMPILE_COMMANDS ON)
ENDMACRO()

MACRO(ARA_SETTINGS_POST TARGET_NAME)
    TARGET_INCLUDE_DIRECTORIES(${TARGET_NAME} PUBLIC ${ARA_INCLUDES})
ENDMACRO()

MACRO(ADD_LIBRARY_ARA TARGET_NAME)
    ARA_SETTINGS_PRE()

    SET(ARGS "${ARGN}")
    SET(SRC_FILES ${ARGS})
    ADD_LIBRARY(${TARGET_NAME} ${SRC_FILES})

    ARA_SETTINGS_POST(${TARGET_NAME})
ENDMACRO()

MACRO(ADD_EXECUTABLE_ARA_INTERNAL TARGET_NAME ADD_PLATFORM_FILES)
    ARA_SETTINGS_PRE()

    # prevent linker argument duplicates when calling macro for multiple targets
    IF(NOT ARA_MACRO_ALREADY_EXECUTED)
        SET(CMAKE_EXE_LINKER_FLAGS
            "${CMAKE_EXE_LINKER_FLAGS} -nostartfiles \
            -T ${CMAKE_BINARY_DIR}/my_link.ld \
            "
        )
    ENDIF()

    PROJECT(${TARGET_NAME} LANGUAGES C CXX ASM)

    SET(ARGS "${ARGN}")
    SET(SRC_FILES ${ARGS})
    IF(${ADD_PLATFORM_FILES})
        LIST(APPEND SRC_FILES 
            ${ARA_COMMON_DIR}/crt0.S
	        ${ARA_COMMON_DIR}/string.c
            ${ARA_COMMON_DIR}/printf.c
            ${ARA_COMMON_DIR}/serial.c   
            ${ARA_COMMON_DIR}/util.c   
            ${ARA_COMMON_DIR}/
        )
    ENDIF()
    # ${ARA_COMMON_DIR}/printf.c

    ADD_EXECUTABLE(${TARGET_NAME} ${SRC_FILES})

    IF(NOT ARA_MACRO_ALREADY_EXECUTED)
        # the following is transferred from https://github.com/pulp-platform/ara/blob/main/apps/Makefile#L48-L53
        ADD_CUSTOM_COMMAND(TARGET ${PROJECT_NAME} # Is the PROJECT_NAME here OK?
            PRE_LINK
            COMMAND chmod +x ${ARA_COMMON_DIR}/script/align_sections.sh
            COMMAND cp ${ARA_COMMON_DIR}/arch.link.ld ${CMAKE_BINARY_DIR}/my_link.ld
            COMMAND ${ARA_COMMON_DIR}/script/align_sections.sh ${MLONMCU_ARA_NR_LANES} ${CMAKE_BINARY_DIR}/my_link.ld
        )
        SET(ARA_MACRO_ALREADY_EXECUTED ON)
    ENDIF()
    
    ARA_SETTINGS_POST(${TARGET_NAME})
ENDMACRO()

MACRO(ADD_EXECUTABLE_ARA TARGET_NAME)
    ADD_EXECUTABLE_ARA_INTERNAL(${TARGET_NAME} ON ${ARGN})
ENDMACRO()

MACRO(ADD_EXECUTABLE_ARA_RAW TARGET_NAME)
    ADD_EXECUTABLE_ARA_INTERNAL(${TARGET_NAME} OFF ${ARGN})
ENDMACRO()
