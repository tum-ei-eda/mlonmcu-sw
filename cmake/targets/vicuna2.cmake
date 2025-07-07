# The Generic system name is used for bare-metal targets (without OS) in CMake
SET(CMAKE_SYSTEM_NAME Generic)
SET(CMAKE_SYSTEM_PROCESSOR vicuna)

SET(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

SET(VICUNA2_BSP_DIR "${CMAKE_CURRENT_LIST_DIR}/vicuna2" CACHE PATH "Path to Vicuna BSP.")

# Linker file settings.
SET(LINK_FILE "${VICUNA2_BSP_DIR}/lld_link.ld")  # Custom (fixed) file
SET(LINK_FILE_OPTION "-T")

SET(BOOT_SRCS ${VICUNA2_BSP_DIR}/crt0.S ${VICUNA2_BSP_DIR}/lib/vicuna_crt.c ${VICUNA2_BSP_DIR}/lib/runtime.c ${VICUNA2_BSP_DIR}/lib/uart.c ${VICUNA2_BSP_DIR}/lib/terminate_benchmark.c)
# TODO: syscalls?

MACRO(COMMON_ADD_EXECUTABLE TARGET_NAME)
    ADD_EXECUTABLE(${TARGET_NAME} ${ARGN} ${BOOT_SRCS})
    TARGET_COMPILE_OPTIONS(${TARGET_NAME} PUBLIC
        $<$<COMPILE_LANGUAGE:CXX>:-std=c++17>
        $<$<COMPILE_LANGUAGE:CXX>:-fno-use-cxa-atexit>
        # $<$<COMPILE_LANGUAGE:C>:-std=gnu99>
    )
    TARGET_INCLUDE_DIRECTORIES(${TARGET_NAME} PUBLIC ${VICUNA2_BSP_DIR}/lib/)
    TARGET_LINK_OPTIONS(${TARGET_NAME} PRIVATE ${LINK_FILE_OPTION} ${LINK_FILE})
    SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES LINK_DEPENDS ${LINK_FILE})
    # TARGET_LINK_OPTIONS(${TARGET_NAME} PRIVATE "--specs=nosys.specs")
    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O verilog ${CMAKE_BINARY_DIR}/bin/${TARGET_NAME} ${CMAKE_BINARY_DIR}/bin/${TARGET_NAME}.hex
        COMMENT "Creating hex")
    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O binary ${CMAKE_BINARY_DIR}/bin/${TARGET_NAME} ${CMAKE_BINARY_DIR}/bin/${TARGET_NAME}.bin
        COMMENT "Creating binary")
    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
        COMMAND srec_cat ${CMAKE_BINARY_DIR}/bin/${TARGET_NAME}.bin -binary -offset 0x0000 -byte-swap 4 -o ${CMAKE_BINARY_DIR}/bin/${TARGET_NAME}.vmem -vmem
        COMMENT "Creating vmem")

    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
        COMMAND realpath ${CMAKE_BINARY_DIR}/bin/${TARGET_NAME}.vmem > ${CMAKE_BINARY_DIR}/bin/${TARGET_NAME}.path
        COMMENT "Creating paths")
ENDMACRO()

MACRO(COMMON_ADD_LIBRARY TARGET_NAME)
    ADD_LIBRARY(${TARGET_NAME} ${ARGN})
    TARGET_INCLUDE_DIRECTORIES(${TARGET_NAME} PUBLIC ${VICUNA2_BSP_DIR}/lib)
    # TARGET_LINK_LIBRARIES(${TARGET_NAME} PRIVATE femto)
    # ADD_DEPENDENCIES(${TARGET_NAME} femto)
    TARGET_COMPILE_OPTIONS(${TARGET_NAME} PUBLIC
        $<$<COMPILE_LANGUAGE:CXX>:-std=c++17>
        $<$<COMPILE_LANGUAGE:CXX>:-fno-use-cxa-atexit>
        # $<$<COMPILE_LANGUAGE:C>:-std=gnu99>
    )
    # IF("${ARGV1}" STREQUAL "OBJECT" AND "${ARGV2}" STREQUAL "IMPORTED")
    # ELSE()
    # ENDIF()
ENDMACRO()

SET(CMAKE_EXE_LINKER_FLAGS
    # "${CMAKE_EXE_LINKER_FLAGS} -nostartfiles -nostdlib -mcmodel=medany -fvisibility=hidden"
    "${CMAKE_EXE_LINKER_FLAGS} -nostartfiles -mcmodel=medany -fvisibility=hidden -fno-use-cxa-atexit"
)

# The linker argument setting will break the cmake test program on 64-bit,
# so disable test program linking for now.
SET(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")
