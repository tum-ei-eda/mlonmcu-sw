# The Generic system name is used for bare-metal targets (without OS) in CMake
SET(CMAKE_SYSTEM_NAME Generic)

SET(CMAKE_SYSTEM_PROCESSOR cv32e40p)

# Linker file settings.
SET(LINK_FILE "${CMAKE_CURRENT_LIST_DIR}/cv32e40p/link.ld")
SET(LINK_FILE_OPTION "-T")

SET(BOOT_SRCS ${CMAKE_CURRENT_LIST_DIR}/cv32e40p/crt0.S ${CMAKE_CURRENT_LIST_DIR}/cv32e40p/syscalls.c ${CMAKE_CURRENT_LIST_DIR}/cv32e40p/vectors.S ${CMAKE_CURRENT_LIST_DIR}/cv32e40p/handlers.S)

MACRO(COMMON_ADD_EXECUTABLE TARGET_NAME)
    ADD_EXECUTABLE(${TARGET_NAME} ${ARGN} ${BOOT_SRCS})
    TARGET_COMPILE_OPTIONS(${TARGET_NAME} PUBLIC
        $<$<COMPILE_LANGUAGE:CXX>:-std=c++17>
        $<$<COMPILE_LANGUAGE:C>:-std=gnu99>
        $<$<COMPILE_LANGUAGE:CXX>:-fno-use-cxa-atexit>
    )
    TARGET_LINK_LIBRARIES(${TARGET_NAME} PRIVATE support)
    TARGET_LINK_OPTIONS(${TARGET_NAME} PRIVATE ${LINK_FILE_OPTION} ${LINK_FILE})
    SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES LINK_DEPENDS ${LINK_FILE})
    # TARGET_LINK_OPTIONS(${TARGET_NAME} PRIVATE "--specs=nosys.specs")
    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O verilog  ${CMAKE_BINARY_DIR}/bin/${TARGET_NAME} ${CMAKE_BINARY_DIR}/bin/${TARGET_NAME}.hex
        COMMENT "Invoking: Hexdump")
ENDMACRO()

MACRO(COMMON_ADD_LIBRARY TARGET_NAME)
    ADD_LIBRARY(${TARGET_NAME} ${ARGN})
    # TARGET_LINK_LIBRARIES(${TARGET_NAME} PRIVATE femto)
    # ADD_DEPENDENCIES(${TARGET_NAME} femto)
    IF("${ARGV1}" STREQUAL "ALIAS")
        # do nothing
    ELSEIF("${ARGV1}" STREQUAL "OBJECT" AND "${ARGV2}" STREQUAL "IMPORTED")
        # do nothing
    ELSE()
        TARGET_COMPILE_OPTIONS(${TARGET_NAME} PUBLIC
            $<$<COMPILE_LANGUAGE:CXX>:-std=c++17>
            $<$<COMPILE_LANGUAGE:C>:-std=gnu99>
            $<$<COMPILE_LANGUAGE:CXX>:-fno-use-cxa-atexit>
        )
    ENDIF()
ENDMACRO()

SET(CMAKE_EXE_LINKER_FLAGS
    "${CMAKE_EXE_LINKER_FLAGS} -nostartfiles -fno-use-cxa-atexit"
)

IF("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    ADD_DEFINITIONS(-DDEBUG_SYSTEM)
ENDIF()

# The linker argument setting will break the cmake test program on 64-bit,
# so disable test program linking for now.
SET(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")
