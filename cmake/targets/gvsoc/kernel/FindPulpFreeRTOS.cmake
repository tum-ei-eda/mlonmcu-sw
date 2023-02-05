# PulpFreeRTOS_FIND_COMPONENTS contains the target name

# if (NOT ("bar" IN_LIST ""))  TODO parse COMPONENTS
#  ...
# endif()

if(NOT (DEFINED ${PulpFreeRTOS_FIND_COMPONENTS}))
    set(PulpFreeRTOS_FIND_COMPONENTS PULPissimo)
endif()

# find path of common source files
SET(PulpFREERTOS_SRC_FILES
    croutine.c
    event_groups.c
    list.c
    queue.c
    tasks.c
    timers.c
)

FOREACH(SRC ${PulpFREERTOS_SRC_FILES})
    STRING(MAKE_C_IDENTIFIER "${SRC}" SRC_CLEAN)
    SET(PulpFREERTOS_${SRC_CLEAN}_FILE PulpFREERTOS_SRC_FILE-NOTFOUND)
    FIND_FILE(PulpFREERTOS_${SRC_CLEAN}_FILE ${SRC}
        HINTS "${CMAKE_CURRENT_LIST_DIR}"
        NO_CMAKE_FIND_ROOT_PATH
        REQUIRED
        )
    LIST(APPEND PulpFREERTOS_SOURCES ${PulpFREERTOS_${SRC_CLEAN}_FILE})
ENDFOREACH()


# find path of heap management files
SET(HEAP_IMP_FILE heap_3.c)
FIND_FILE(HEAP_IMP_SOURCE ${HEAP_IMP_FILE}
    HINTS "${CMAKE_CURRENT_LIST_DIR}/portable/MemMang"
    NO_CMAKE_FIND_ROOT_PATH
    REQUIRED
    )

# find path of portable source files
SET(PulpFREERTOS_PORTABLE_SRC_FILES
    port.c
    portASM.S
)

FOREACH(SRC ${PulpFREERTOS_PORTABLE_SRC_FILES})
    STRING(MAKE_C_IDENTIFIER "${SRC}" SRC_CLEAN)
    SET(PulpFREERTOS_${SRC_CLEAN}_FILE PulpFREERTOS_SRC_FILE-NOTFOUND)
    FIND_FILE(PulpFREERTOS_${SRC_CLEAN}_FILE ${SRC}
        PATH_SUFFIXES RISC-V
        HINTS "${CMAKE_CURRENT_LIST_DIR}/portable/GCC"
        NO_CMAKE_FIND_ROOT_PATH
        REQUIRED)
    LIST(APPEND PulpFREERTOS_PORTABLE_SOURCES ${PulpFREERTOS_${SRC_CLEAN}_FILE})
ENDFOREACH()

# find dir containing common headers
SET(FREERTOS_HEADERS
    croutine.h
    deprecated_definitions.h
    event_groups.h
    FreeRTOS.h
    list.h
    message_buffer.h
    mpu_prototypes.h
    mpu_wrappers.h
    portable.h
    projdefs.h
    queue.h
    semphr.h
    StackMacros.h
    task.h
    timers.h
    )

FIND_PATH(FREERTOS_COMMON_INC_DIR ${FREERTOS_HEADERS}
    PATH_SUFFIXES include
    HINTS "${CMAKE_CURRENT_LIST_DIR}"
    NO_CMAKE_FIND_ROOT_PATH
    REQUIRED
    )

# find portable macro
SET(PORTMACRO_RISCV_HEADER portmacro.h)
FIND_PATH(FREERTOS_PORTMACRO_INC_DIR ${PORTMACRO_RISCV_HEADER}
    PATH_SUFFIXES RISC-V
    HINTS "${CMAKE_CURRENT_LIST_DIR}/portable/GCC"
    NO_CMAKE_FIND_ROOT_PATH
    REQUIRED
    )

# find chip specific extensions
SET(CHIP_SPECIFIC_EXTENSIONS_HEADER freertos_risc_v_chip_specific_extensions.h)
message("${CMAKE_CURRENT_LIST_DIR}/portable/GCC/RISC-V/${PulpFreeRTOS_FIND_COMPONENTS}")
FIND_PATH(PulpFREERTOS_CHIP_SPECIFIC_EXTENSIONS_DIR ${CHIP_SPECIFIC_EXTENSIONS_HEADER}
    HINTS "${CMAKE_CURRENT_LIST_DIR}/portable/GCC/RISC-V/chip_specific_extensions/${PulpFreeRTOS_FIND_COMPONENTS}"
    NO_CMAKE_FIND_ROOT_PATH
    REQUIRED
    )