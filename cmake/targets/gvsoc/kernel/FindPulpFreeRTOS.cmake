# PulpFreeRTOS_FIND_COMPONENTS contains the target name

# if (NOT ("bar" IN_LIST ""))  TODO parse COMPONENTS
#  ...
# endif()

if(NOT PulpFreeRTOS_FIND_COMPONENTS)
    set(PulpFreeRTOS_FIND_COMPONENTS "PULPissimo")
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
        )
    LIST(APPEND PulpFREERTOS_SOURCES ${PulpFREERTOS_${SRC_CLEAN}_FILE})
ENDFOREACH()

FIND_FILE(HEAP_IMP_SOURCE ${HEAP_IMP_FILE}
    PATH_SUFFIXES MemMang
    HINTS ${STM32Cube_DIR}/Middlewares/Third_Party/FreeRTOS/Source/portable
    NO_CMAKE_FIND_ROOT_PATH
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
    )

# find portable macro

FIND_PATH(FREERTOS_PORTMACRO_INC_DIR ${PORTMACRO_RISCV_HEADER}
    PATH_SUFFIXES RISC-V
    HINTS "${CMAKE_CURRENT_LIST_DIR}/portable/GCC"
    NO_CMAKE_FIND_ROOT_PATH
    )

# find chip specific extensions

FIND_PATH(FREERTOS_CHIP_SPECIFIC_EXTENSIONS_DIR ${PORTMACRO_RISCV_HEADER}
    PATH_SUFFIXES ${PulpFreeRTOS_FIND_COMPONENTS}
    HINTS "${CMAKE_CURRENT_LIST_DIR}/portable/GCC/RISC-V"
    NO_CMAKE_FIND_ROOT_PATH
    )