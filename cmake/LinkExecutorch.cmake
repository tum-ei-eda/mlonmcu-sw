SET(EXECUTORCH_SRC_DIR
    "/path/to/executorch"
    CACHE PATH "Executorch source directory"
)
SET(EXECUTORCH_PTE_FILE_PATH
    "/path/to/executorch/model.pte"
    CACHE PATH "Executorch PTE file"
)
set(ET_DIR_PATH ${EXECUTORCH_SRC_DIR})
set(ET_INCLUDE_PATH ${EXECUTORCH_SRC_DIR}/src/executorch/include)
set(ET_INCLUDE_PATH2 ${EXECUTORCH_SRC_DIR}/..)
set(ET_PTE_FILE_PATH ${EXECUTORCH_PTE_FILE_PATH})

include(${EXECUTORCH_SRC_DIR}/tools/cmake/common/preset.cmake)

set(PYTHON_EXECUTABLE "python3")


# set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}")
set_overridable_option(EXECUTORCH_BUILD_EXECUTOR_RUNNER OFF)
set_overridable_option(EXECUTORCH_BUILD_EXTENSION_FLAT_TENSOR OFF)
set_overridable_option(EXECUTORCH_BUILD_EXTENSION_DATA_LOADER OFF)
set_overridable_option(EXECUTORCH_BUILD_ARM_BAREMETAL ON)
# set_overridable_option(EXECUTORCH_BUILD_RISCV_BAREMETAL ON)
set_overridable_option(EXECUTORCH_BUILD_KERNELS_QUANTIZED ON)
set_overridable_option(EXECUTORCH_BUILD_EXTENSION_RUNNER_UTIL ON)
set_overridable_option(EXECUTORCH_BUILD_CORTEX_M OFF) # ?
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

set(EXECUTORCH_ROOT ${ET_DIR_PATH})
include(${ET_DIR_PATH}/tools/cmake/Utils.cmake)
include(${ET_DIR_PATH}/tools/cmake/Codegen.cmake)


set(EXECUTORCH_SELECT_OPS_LIST "")
set(EXECUTORCH_SELECT_OPS_MODEL "${ET_PTE_FILE_PATH}")

gen_selected_ops(
  LIB_NAME
  "mlonmcu_portable_ops_lib"
  OPS_SCHEMA_YAML
  ""
  ROOT_OPS
  "${EXECUTORCH_SELECT_OPS_LIST}"
  INCLUDE_ALL_OPS
  ""
  OPS_FROM_MODEL
  "${EXECUTORCH_SELECT_OPS_MODEL}"
  DTYPE_SELECTIVE_BUILD
  "${EXECUTORCH_ENABLE_DTYPE_SELECTIVE_BUILD}"
)

generate_bindings_for_kernels(
  LIB_NAME "mlonmcu_portable_ops_lib" FUNCTIONS_YAML
  ${ET_DIR_PATH}/kernels/portable/functions.yaml DTYPE_SELECTIVE_BUILD
  "${EXECUTORCH_ENABLE_DTYPE_SELECTIVE_BUILD}"
)
gen_operators_lib(
  LIB_NAME
  "mlonmcu_portable_ops_lib"
  KERNEL_LIBS
  portable_kernels
  DEPS
  executorch
  DTYPE_SELECTIVE_BUILD
  "${EXECUTORCH_ENABLE_DTYPE_SELECTIVE_BUILD}"
)
set(mlonmcu_executor_runner_link)
list(
  APPEND
  mlonmcu_executor_runner_link
  extension_runner_util
  # ethosu_target_init
  executorch
  quantized_ops_lib
  # cortex_m_ops_lib
  # "-Wl,--whole-archive"
  # # executorch_delegate_ethos_u
  # quantized_kernels
  # # cortex_m_kernels
  # portable_kernels
  # mlonmcu_portable_ops_lib
  # "-Wl,--no-whole-archive"
  # -Xlinker
  # -Map=riscv_executor_runner.map
)
# executorch_target_link_options_shared_lib(mlonmcu_portable_ops_lib)

add_library(portable_ops_whole_archive INTERFACE)

target_link_options(portable_ops_whole_archive INTERFACE
  -Wl,--whole-archive
)

target_link_libraries(portable_ops_whole_archive INTERFACE
  quantized_kernels
  portable_kernels
  mlonmcu_portable_ops_lib
)

target_link_options(portable_ops_whole_archive INTERFACE
  -Wl,--no-whole-archive
)
list(
  APPEND
  mlonmcu_executor_runner_link
  portable_ops_whole_archive
)
list(
  APPEND
  mlonmcu_executor_runner_link
  "-Wl,--whole-archive $<TARGET_FILE:portable_kernels> -Wl,--no-whole-archive"
  "-Wl,--whole-archive $<TARGET_FILE:quantized_kernels> -Wl,--no-whole-archive"
  "-Wl,--whole-archive $<TARGET_FILE:mlonmcu_portable_ops_lib> -Wl,--no-whole-archive"
)
