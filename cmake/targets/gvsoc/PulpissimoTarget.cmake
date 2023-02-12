SET(GVSOC_LIB_DIR ${CMAKE_CURRENT_LIST_DIR})
SET(GVSOC_TARGET_LIB_DIR ${GVSOC_LIB_DIR}/target/pulpissimo)
SET(GVSOC_FREERTOS_KERNEL ${GVSOC_LIB_DIR}/kernel)

SET(USE_FREERTOS true)

find_path(FreeRTOSConfig FreeRTOSConfig.h
          HINTS ${CMAKE_CURRENT_LIST_DIR}/demos REQUIRED)
find_path(chip_specific_extensions freertos_risc_v_chip_specific_extensions.h
          HINTS ${GVSOC_FREERTOS_KERNEL}/portable/GCC/RISC-V/chip_specific_extensions/PULPissimo REQUIRED)
# MESSAGE("free ${FreeRTOSConfig}")
SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${GVSOC_FREERTOS_KERNEL}")
IF(${USE_FREERTOS})
    FIND_PACKAGE(PulpFreeRTOS COMPONENTS ${FREERTOS_COMP_LIST} REQUIRED)
ENDIF()


MACRO(GVSOC_PULPISSIMO_SETTINGS_PRE)
    IF(${USE_FREERTOS})
        SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "GVSOC_FREERTOS_KERNEL")
        FIND_PACKAGE(PulpFreeRTOS COMPONENTS ${FREERTOS_COMP_LIST} REQUIRED)
        SET(GVSOC_PULPISSIMO_INCLUDES
            ${GVSOC_TARGET_LIB_DIR}/include
            ${GVSOC_LIB_DIR}/target/arch
            ${GVSOC_LIB_DIR}/libc/malloc/include
            ${GVSOC_LIB_DIR}/drivers/include
            ${FREERTOS_COMMON_INC_DIR}
            ${FREERTOS_PORTMACRO_INC_DIR}
            ${PulpFREERTOS_CHIP_SPECIFIC_EXTENSIONS_DIR}
            ${GVSOC_LIB_DIR}/demos # this is to include FreeRTOSConfig.h
        )
    ELSE()
        SET(GVSOC_PULPISSIMO_INCLUDES
                ${GVSOC_TARGET_LIB_DIR}/include
                ${GVSOC_LIB_DIR}/target/arch
                ${GVSOC_LIB_DIR}/libc/malloc/include
                ${GVSOC_LIB_DIR}/drivers/include
        )
    ENDIF()

    

    SET(CMAKE_EXPORT_COMPILE_COMMANDS ON)
ENDMACRO()

MACRO(GVSOC_PULPISSIMO_SETTINGS_POST TARGET_NAME)
    TARGET_INCLUDE_DIRECTORIES(${TARGET_NAME} INTERFACE ${GVSOC_PULPISSIMO_INCLUDES})
ENDMACRO()

MACRO(ADD_LIBRARY_GVSOC_PULPISSIMO TARGET_NAME)
    GVSOC_PULPISSIMO_SETTINGS_PRE()

    SET(ARGS "${ARGN}")
    SET(SRC_FILES ${ARGS})
    ADD_LIBRARY(${TARGET_NAME} ${SRC_FILES})

    GVSOC_PULPISSIMO_SETTINGS_POST(${TARGET_NAME})
ENDMACRO()

MACRO(ADD_EXECUTABLE_GVSOC_PULPISSIMO_INTERNAL TARGET_NAME ADD_PLATFORM_FILES)
    GVSOC_PULPISSIMO_SETTINGS_PRE()

    
    # prevent linker argument duplicates when calling macro for multiple targets
    IF(NOT GVSOC_PULPISSIMO_MACRO_ALREADY_EXECUTED)
        SET(CMAKE_EXE_LINKER_FLAGS
            "${CMAKE_EXE_LINKER_FLAGS} -nostartfiles \
            -T ${GVSOC_TARGET_LIB_DIR}/link.ld \
            "
        )
    ENDIF()

    PROJECT(${TARGET_NAME} LANGUAGES C CXX ASM)
    message("Compiler Version: ${CMAKE_CXX_COMPILER_VERSION}")

    SET(ARGS "${ARGN}")
    SET(SRC_FILES ${ARGS})
    IF(${ADD_PLATFORM_FILES})

        IF(${USE_FREERTOS})
            LIST(APPEND SRC_FILES 
                ${GVSOC_TARGET_LIB_DIR}/crt0.S
                ${GVSOC_TARGET_LIB_DIR}/vectors.S
                ${GVSOC_TARGET_LIB_DIR}/system.c
                ${GVSOC_LIB_DIR}/libc/malloc/malloc_internal.c
                ${GVSOC_LIB_DIR}/libc/malloc/cl_l1_malloc.c
                ${GVSOC_LIB_DIR}/libc/syscalls.c
                ${GVSOC_LIB_DIR}/libc/pulp_malloc.c 
                
                # ${GVSOC_LIB_DIR}/drivers/cluster/cl_to_fc_delegate.c
                # ${GVSOC_LIB_DIR}/drivers/cluster/fc_to_cl_delegate.c
                ${GVSOC_LIB_DIR}/drivers/uart.c
                ${GVSOC_LIB_DIR}/drivers/spi.c
                ${GVSOC_LIB_DIR}/drivers/i2c.c
                ${GVSOC_LIB_DIR}/drivers/fll.c
                ${GVSOC_LIB_DIR}/drivers/timer_irq.c
                ${GVSOC_LIB_DIR}/drivers/pclint.c
                ${GVSOC_LIB_DIR}/drivers/soc_eu.c
                ${GVSOC_LIB_DIR}/drivers/gpio.c
                ${GVSOC_LIB_DIR}/drivers/pinmux.c
                ${GVSOC_LIB_DIR}/drivers/fc_event.c
                ${GVSOC_LIB_DIR}/drivers/pmsis_task.c
                ${GVSOC_LIB_DIR}/drivers/device.c
                ${PulpFREERTOS_PORTABLE_SOURCES}
                ${PulpFREERTOS_SOURCES}
                ${HEAP_IMP_SOURCE}
            )
        ELSE()
            LIST(APPEND SRC_FILES
                ${GVSOC_TARGET_LIB_DIR}/crt0.S
                ${GVSOC_TARGET_LIB_DIR}/vectors_metal.S
                ${GVSOC_TARGET_LIB_DIR}/system_metal.c
                ${GVSOC_LIB_DIR}/libc/malloc/malloc_internal.c
                ${GVSOC_LIB_DIR}/libc/malloc/cl_l1_malloc.c
                ${GVSOC_LIB_DIR}/libc/syscalls.c
                ${GVSOC_LIB_DIR}/libc/pulp_malloc.c 
            )
        ENDIF()
    ENDIF()

    ADD_EXECUTABLE(${TARGET_NAME} ${SRC_FILES})
    
    GVSOC_PULPISSIMO_SETTINGS_POST(${TARGET_NAME})
ENDMACRO()

MACRO(ADD_EXECUTABLE_GVSOC_PULPISSIMO TARGET_NAME)
    ADD_EXECUTABLE_GVSOC_PULPISSIMO_INTERNAL(${TARGET_NAME} ON ${ARGN})
ENDMACRO()

MACRO(ADD_EXECUTABLE_GVSOC_PULPISSIMO_RAW TARGET_NAME)
    ADD_EXECUTABLE_GVSOC_PULPISSIMO_INTERNAL(${TARGET_NAME} OFF ${ARGN})
ENDMACRO()
