SET(CMAKE_SYSTEM_NAME Generic)
SET(CMAKE_SYSTEM_PROCESSOR "cortex-m55") # TODO: make this variable
IF(NOT ARM_CPU)
    SET(ARM_CPU ${CMAKE_SYSTEM_PROCESSOR})
ELSE()
    SET(CMAKE_SYSTEM_PROCESSOR ${ARM_CPU})
ENDIF()

SET(ETHOSU_PLATFORM_DIR
    # ""
    "/tmp/arm/ethosu/core_platform"
    CACHE PATH "Path to ethosu platform."
)
SET(CMSIS_DIR
    ""
    CACHE PATH "Path to CMSIS."
)
SET(CMSISNN_DIR
    ""
    CACHE PATH "Path to CMSIS-NN."
)

ADD_COMPILE_OPTIONS(
    -fomit-frame-pointer
    # -Werror
    -Wunused-variable
    -Wunused-function
    -Wno-redundant-decls
)

SET(FVP_CORSTONE_300_PATH
    "${CMSISNN_DIR}/CMSIS/NN/Tests/UnitTest/Corstone-300"
    CACHE PATH "Dependencies for using FVP based on Arm Corstone-300 software."
)
# set(CMAKE_EXECUTABLE_SUFFIX ".elf")

# ADD_LIBRARY(
#     retarget STATIC
#     # ${FVP_CORSTONE_300_PATH}/retarget.c
#     ${CMAKE_CURRENT_LIST_DIR}/corstone300/retarget.c
#     # ${FVP_CORSTONE_300_PATH}/uart.c)
#     ${CMAKE_CURRENT_LIST_DIR}/corstone300/uart.c
# )

add_library(uart_common INTERFACE)

target_include_directories(uart_common INTERFACE
                           ${ETHOSU_PLATFORM_DIR}/drivers/uart/include
                           ${CMAKE_CURRENT_BINARY_DIR})

# UART configuration (Can be overriden from user project, default value is for  target "Corestone-300")
set(UART0_BASE        "0x49303000" CACHE STRING "UART base address")
set(UART0_BAUDRATE    "115200"     CACHE STRING "UART baudrate")
set(SYSTEM_CORE_CLOCK "25000000"   CACHE STRING "System core clock (Hz)")

# Generate UART configuration file
configure_file("${ETHOSU_PLATFORM_DIR}/drivers/uart/uart_config.h.in" "${CMAKE_CURRENT_BINARY_DIR}/uart_config.h")

add_library(uart_driver STATIC ${ETHOSU_PLATFORM_DIR}/drivers/uart/src/uart_cmsdk_apb.c)
target_include_directories(uart_driver PUBLIC ${ETHOSU_PLATFORM_DIR}/drivers/uart/include ${CMAKE_CURRENT_BINARY_DIR})
target_link_libraries(uart_driver PUBLIC uart_common)

# Build CMSIS startup dependencies based on TARGET_CPU.
STRING(REGEX REPLACE "^cortex-m([0-9]+).*$" "ARMCM\\1" ARM_CPU_SHORT ${CMAKE_SYSTEM_PROCESSOR})
IF(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "cortex-m33")
    SET(ARM_FEATURES "_DSP_FP")
ELSEIF(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "cortex-m4")
    SET(ARM_FEATURES "_FP")
ELSEIF(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "cortex-m7")
    SET(ARM_FEATURES "_DP")
ELSE()
    SET(ARM_FEATURES "")
ENDIF()
ADD_LIBRARY(cmsis_startup STATIC)
SET(CMSIS_STARTUP_SRCS ${CMSIS_DIR}/Device/ARM/${ARM_CPU_SHORT}/Source/startup_${ARM_CPU_SHORT}.c
                       ${CMSIS_DIR}/Device/ARM/${ARM_CPU_SHORT}/Source/system_${ARM_CPU_SHORT}.c
)
# message(STATUS "CMSIS_STARTUP_SRCS=${CMSIS_STARTUP_SRCS}")
TARGET_SOURCES(cmsis_startup PRIVATE ${CMSIS_STARTUP_SRCS})
TARGET_INCLUDE_DIRECTORIES(
    cmsis_startup PUBLIC ${CMSIS_DIR}/Device/ARM/${ARM_CPU_SHORT}/Include ${CMSIS_DIR}/CMSIS/Core/Include
)
# TARGET_COMPILE_OPTIONS(cmsis_startup INTERFACE -include${ARM_CPU_SHORT}${ARM_FEATURES}.h)
TARGET_COMPILE_DEFINITIONS(cmsis_startup PRIVATE ${ARM_CPU_SHORT}${ARM_FEATURES})

# Linker file settings.
SET(LINK_FILE "${CMAKE_CURRENT_LIST_DIR}/corstone300/linker.ld")
SET(LINK_FILE_OPTION "-T")
SET(LINK_ENTRY_OPTION "")
SET(LINK_ENTRY "")

MACRO(COMMON_ADD_EXECUTABLE TARGET_NAME)
    ADD_EXECUTABLE(${TARGET_NAME} ${ARGN} ${ETHOSU_PLATFORM_DIR}/targets/corstone-300/retarget.c)
    # TARGET_LINK_LIBRARIES(${TARGET_NAME} PRIVATE retarget)
    TARGET_LINK_LIBRARIES(${TARGET_NAME} PRIVATE uart_driver)
    TARGET_LINK_LIBRARIES(${TARGET_NAME} PRIVATE $<TARGET_OBJECTS:cmsis_startup> cmsis_startup)
    TARGET_INCLUDE_DIRECTORIES(${TARGET_NAME} PUBLIC ${ETHOSU_PLATFORM_DIR}/drivers/uart/include)
    # ADD_DEPENDENCIES(${TARGET_NAME} retarget cmsis_startup)
    # ADD_DEPENDENCIES(${TARGET_NAME} uart_driver cmsis_startup)
    TARGET_COMPILE_DEFINITIONS(${TARGET_NAME} PUBLIC USING_FVP_CORSTONE_300)
    TARGET_LINK_OPTIONS(${TARGET_NAME} PRIVATE ${LINK_FILE_OPTION} ${LINK_FILE} ${LINK_ENTRY_OPTION} ${LINK_ENTRY})
    SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES LINK_DEPENDS ${LINK_FILE})
    TARGET_LINK_OPTIONS(${TARGET_NAME} PRIVATE "--specs=nosys.specs")
ENDMACRO()

MACRO(COMMON_ADD_LIBRARY TARGET_NAME)
    ADD_LIBRARY(${TARGET_NAME} ${ARGN})
    TARGET_INCLUDE_DIRECTORIES(${TARGET_NAME} PUBLIC ${ETHOSU_PLATFORM_DIR}/drivers/uart/include)
    # IF(ARM_DSP)
    #     IF(NOT CMSIS_DIR)
    #         MESSAGE(FATAL_ERROR "Missing value: CMSIS_DIR")
    #     ENDIF()
    #     TARGET_INCLUDE_DIRECTORIES(
    #         ${TARGET_NAME} PUBLIC ${CMSIS_DIR}/CMSIS/Core/Include ${CMSIS_DIR}/CMSIS/DSP/Include
    #                               ${CMSIS_DIR}/CMSIS/NN/Include
    #     )
    # ENDIF()
ENDMACRO()

# The linker argument setting will break the cmake test program on 64-bit,
# so disable test program linking for now.
SET(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")
