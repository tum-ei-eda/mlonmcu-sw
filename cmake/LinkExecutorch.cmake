SET(EXECUTORCH_SRC_DIR
    "/path/to/executorch"
    CACHE PATH "Executorch source directory"
)

# set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}")
set_overridable_option(EXECUTORCH_BUILD_EXECUTOR_RUNNER OFF)
set_overridable_option(EXECUTORCH_BUILD_EXTENSION_FLAT_TENSOR OFF)
set_overridable_option(EXECUTORCH_BUILD_EXTENSION_DATA_LOADER OFF)
set_overridable_option(EXECUTORCH_BUILD_ARM_BAREMETAL ON)
# set_overridable_option(EXECUTORCH_BUILD_RISCV_BAREMETAL ON)
set_overridable_option(EXECUTORCH_BUILD_KERNELS_QUANTIZED ON)
set_overridable_option(EXECUTORCH_BUILD_EXTENSION_RUNNER_UTIL ON)
set_overridable_option(EXECUTORCH_BUILD_CORTEX_M ON) # ?
set_overridable_option(EXECUTORCH_ENABLE_LOGGING ON)
set_overridable_option(EXECUTORCH_BUILD_PTHREADPOOL OFF)

define_overridable_option(
  EXECUTORCH_BUILD_ARM_ETDUMP "Build etdump support for Arm" BOOL OFF
)

if("${EXECUTORCH_BUILD_ARM_ETDUMP}")
  set(EXECUTORCH_BUILD_DEVTOOLS ON)
  set(EXECUTORCH_ENABLE_EVENT_TRACER ON)
  set(FLATCC_ALLOW_WERROR OFF)
else()
  set(EXECUTORCH_ENABLE_EVENT_TRACER OFF)
endif()

add_subdirectory(${EXECUTORCH_SRC_DIR} executorch)
