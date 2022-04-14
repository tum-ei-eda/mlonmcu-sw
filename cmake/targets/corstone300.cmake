# SET(CMAKE_TOOLCHAIN_FILE "?")

set(CMAKE_SYSTEM_PROCESSOR "cortex-m55")  # TODO: make this variable
set(ARM_CPU ${CMAKE_SYSTEM_PROCESSOR})
set(CMSIS_PATH "" CACHE PATH "Path to CMSIS.")

add_compile_options(-Ofast
                    -fomit-frame-pointer
#                    -Werror
                    -Wunused-variable
                    -Wunused-function
                    -Wno-redundant-decls)

set(FVP_CORSTONE_300_PATH "${CMSIS_PATH}/CMSIS/NN/Tests/UnitTest/Corstone-300" CACHE PATH
        "Dependencies for using FVP based on Arm Corstone-300 software.")
# set(CMAKE_EXECUTABLE_SUFFIX ".elf")

add_library(retarget STATIC
    ${FVP_CORSTONE_300_PATH}/retarget.c
    ${FVP_CORSTONE_300_PATH}/uart.c)

# Build CMSIS startup dependencies based on TARGET_CPU.
string(REGEX REPLACE "^cortex-m([0-9]+)$" "ARMCM\\1" ARM_CPU_SHORT ${CMAKE_SYSTEM_PROCESSOR})
if(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "cortex-m33")
    set(ARM_FEATURES "_DSP_FP")
elseif(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "cortex-m4")
    set(ARM_FEATURES "_FP")
elseif(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "cortex-m7")
    set(ARM_FEATURES "_DP")
else()
    set(ARM_FEATURES "")
endif()
add_library(cmsis_startup STATIC)
SET(CMSIS_STARTUP_SRCS
    ${CMSIS_PATH}/Device/ARM/${ARM_CPU_SHORT}/Source/startup_${ARM_CPU_SHORT}.c
    ${CMSIS_PATH}/Device/ARM/${ARM_CPU_SHORT}/Source/system_${ARM_CPU_SHORT}.c
)
# message(STATUS "CMSIS_STARTUP_SRCS=${CMSIS_STARTUP_SRCS}")
target_sources(cmsis_startup PRIVATE ${CMSIS_STARTUP_SRCS})
target_include_directories(cmsis_startup PUBLIC
    ${CMSIS_PATH}/Device/ARM/${ARM_CPU_SHORT}/Include
    ${CMSIS_PATH}/CMSIS/Core/Include)
target_compile_options(cmsis_startup INTERFACE -include${ARM_CPU_SHORT}${ARM_FEATURES}.h)
target_compile_definitions(cmsis_startup PRIVATE ${ARM_CPU_SHORT}${ARM_FEATURES})

# Linker file settings.
set(LINK_FILE "${FVP_CORSTONE_300_PATH}/linker" CACHE PATH "Linker file.")
set(LINK_FILE "${FVP_CORSTONE_300_PATH}/linker.ld")
set(LINK_FILE_OPTION "-T")
set(LINK_ENTRY_OPTION "")
set(LINK_ENTRY "")

SET(TARGET_SYSTEM_LIBS retarget cmsis_startup)
SET(TARGET_SYSTEM_DEFS USING_FVP_CORSTONE_300)
SET(TARGET_SYSTEM_LINK_OPTIONS ${LINK_FILE_OPTION} ${LINK_FILE} ${LINK_ENTRY_OPTION} ${LINK_ENTRY})
SET(TARGET_SYSTEM_PROPERTIES_LINK_DEPENDS ${LINK_FILE})

MACRO(COMMON_ADD_EXECUTABLE TARGET_NAME)
    ADD_EXECUTABLE(${TARGET_NAME} ${ARGN})
    target_link_libraries(${TARGET_NAME} PRIVATE retarget)
    target_link_libraries(${TARGET_NAME} PRIVATE $<TARGET_OBJECTS:cmsis_startup> cmsis_startup)
    add_dependencies(${TARGET_NAME} retarget cmsis_startup)
    target_compile_definitions(${TARGET_NAME} PUBLIC USING_FVP_CORSTONE_300)
    target_link_options(${TARGET_NAME} PRIVATE ${LINK_FILE_OPTION} ${LINK_FILE} ${LINK_ENTRY_OPTION} ${LINK_ENTRY})
    set_target_properties(${TARGET_NAME} PROPERTIES LINK_DEPENDS ${LINK_FILE})
    target_link_options(${TARGET_NAME} PRIVATE "--specs=nosys.specs")
ENDMACRO()


# Alternative: target_pre target_post hooks?
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")
