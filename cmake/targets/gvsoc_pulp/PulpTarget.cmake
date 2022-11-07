SET(PULP_LIB_DIR ${CMAKE_CURRENT_LIST_DIR})

MACRO(PULP_SETTINGS_PRE)
    SET(PULP_INCLUDES
            ${PULP_LIB_DIR}/target/pulp/include
            ${PULP_LIB_DIR}/target/arch
            ${PULP_LIB_DIR}/libc/malloc/include
            ${PULP_LIB_DIR}/drivers/include
    )

    SET(CMAKE_EXPORT_COMPILE_COMMANDS ON)
ENDMACRO()

MACRO(PULP_SETTINGS_POST TARGET_NAME)
    TARGET_INCLUDE_DIRECTORIES(${TARGET_NAME} PUBLIC ${PULP_INCLUDES})
ENDMACRO()

MACRO(ADD_LIBRARY_PULP TARGET_NAME)
    PULP_SETTINGS_PRE()

    SET(ARGS "${ARGN}")
    SET(SRC_FILES ${ARGS})
    ADD_LIBRARY(${TARGET_NAME} ${SRC_FILES})

    PULP_SETTINGS_POST(${TARGET_NAME})
ENDMACRO()

MACRO(ADD_EXECUTABLE_PULP_INTERNAL TARGET_NAME ADD_PLATFORM_FILES)
    PULP_SETTINGS_PRE()

    # prevent linker argument duplicates when calling macro for multiple targets
    IF(NOT PULP_MACRO_ALREADY_EXECUTED)
        SET(CMAKE_EXE_LINKER_FLAGS
            "${CMAKE_EXE_LINKER_FLAGS} -nostartfiles \
            -T ${PULP_LIB_DIR}/target/pulp/link.ld \
            "
        )
    ENDIF()

    PROJECT(${TARGET_NAME} LANGUAGES C CXX ASM)

    SET(ARGS "${ARGN}")
    SET(SRC_FILES ${ARGS})
    IF(${ADD_PLATFORM_FILES})
        LIST(APPEND SRC_FILES 
            ${PULP_LIB_DIR}/target/pulp/system_metal.c
            ${PULP_LIB_DIR}/target/pulp/crt0.S
            ${PULP_LIB_DIR}/target/pulp/vectors_metal.S
	        ${PULP_LIB_DIR}/libc/malloc/malloc_internal.c
            ${PULP_LIB_DIR}/libc/malloc/cl_l1_malloc.c
            ${PULP_LIB_DIR}/libc/syscalls.c
            ${PULP_LIB_DIR}/libc/pulp_malloc.c              
        )
    ENDIF()

    ADD_EXECUTABLE(${TARGET_NAME} ${SRC_FILES})
    
    PULP_SETTINGS_POST(${TARGET_NAME})
ENDMACRO()

MACRO(ADD_EXECUTABLE_PULP TARGET_NAME)
    ADD_EXECUTABLE_PULP_INTERNAL(${TARGET_NAME} ON ${ARGN})
ENDMACRO()

MACRO(ADD_EXECUTABLE_PULP_RAW TARGET_NAME)
    ADD_EXECUTABLE_PULP_INTERNAL(${TARGET_NAME} OFF ${ARGN})
ENDMACRO()
