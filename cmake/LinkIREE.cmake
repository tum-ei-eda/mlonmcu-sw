SET(IREE_SRC_DIR
    "/data/work/code/iree"
    CACHE PATH "IREE source directory"
)
SET(IREE_INSTALL_DIR
    "/data/work/code/iree/install"
    CACHE PATH "IREE install directory"
)

SET(CMAKE_SYSTEM_PROCESSOR riscv32) # TODO: move to tc!
SET(IREE_BUILD_TESTS OFF CACHE BOOL "" FORCE)
SET(IREE_BUILD_SAMPLES OFF CACHE BOOL "" FORCE)
SET(IREE_BUILD_COMPILER OFF CACHE BOOL "" FORCE)
SET(IREE_ENABLE_THREADING OFF CACHE BOOL "" FORCE)
SET(IREE_HAL_DRIVER_DEFAULTS OFF CACHE BOOL "" FORCE)
SET(IREE_HAL_DRIVER_LOCAL_SYNC ON CACHE BOOL "" FORCE)
SET(IREE_HAL_EXECUTABLE_LOADER_DEFAULTS OFF CACHE BOOL "" FORCE)
SET(IREE_HAL_EXECUTABLE_LOADER_VMVX_MODULE ON CACHE BOOL "" FORCE)
SET(IREE_HAL_EXECUTABLE_LOADER_EMBEDDED_ELF ON CACHE BOOL "" FORCE)
SET(IREE_HAL_EXECUTABLE_PLUGIN_DEFAULTS OFF CACHE BOOL "" FORCE)
SET(IREE_HAL_EXECUTABLE_PLUGIN_EMBEDDED_ELF ON CACHE BOOL "" FORCE)
SET(IREE_BUILD_BINDINGS_TFLITE OFF CACHE BOOL "" FORCE)
SET(IREE_BUILD_BINDINGS_TFLITE_JAVA OFF CACHE BOOL "" FORCE)
SET(IREE_ERROR_ON_MISSING_SUBMODULES OFF CACHE BOOL "" FORCE)
SET(IREE_HOST_BIN_DIR=${IREE_INSTALL_DIR}/build/bin)

ADD_COMPILE_DEFINITIONS(
  IREE_PLATFORM_GENERIC=1
  IREE_SYNCHRONIZATION_DISABLE_UNSAFE=1
  IREE_FILE_IO_ENABLE=0
  # IREE_TIME_NOW_FN="{ return 0; }"
  # '-DIREE_WAIT_UNTIL_FN(ns)= (true)'
  # '-DIREE_MEMORY_FLUSH_ICACHE(start, end)= do { } while (0)'
)
# -march=rv32gc -mabi=ilp32d -Wno-error=format -Wno-error=char-subscripts" \


# ADD_SUBDIRECTORY(${IREE_SRC_DIR} iree_runtime)
ADD_SUBDIRECTORY(${IREE_SRC_DIR} iree)

get_target_property(real_target iree::base ALIASED_TARGET)
message(STATUS "REAL target for iree::runtime = ${real_target}")
# get_target_property(type_of_target iree_base_internal_time TYPE)
# message(STATUS "Target iree_base_internal_time is of type: ${type_of_target}")


# target_compile_options(iree_base_internal_time PRIVATE "-include iree_platform_overrides.h")
target_compile_options(iree_base_internal_time PRIVATE "-include${CMAKE_CURRENT_LIST_DIR}/frameworks/iree_platform_overrides.h")
# target_include_directories(iree_base_internal_time PRIVATE ${CMAKE_CURRENT_LIST_DIR}/frameworks)
target_compile_options(iree_base_base PRIVATE "-include${CMAKE_CURRENT_LIST_DIR}/frameworks/iree_platform_overrides.h")
# target_include_directories(iree_base_base PRIVATE ${CMAKE_CURRENT_LIST_DIR}/frameworks)
# target_compile_options(time INTERFACE "-include=iree_platform_overrides.h")
target_compile_options(iree_base_base PRIVATE -Wno-error=format -Wno-error=char-subscripts)
target_compile_options(iree_vm_impl PRIVATE -Wno-error=format -Wno-error=char-subscripts)
target_compile_options(iree_vm_bytecode_utils_utils PRIVATE -Wno-error=format -Wno-error=char-subscripts)
target_compile_options(iree_hal_hal PRIVATE -Wno-error=format -Wno-error=char-subscripts)
target_compile_options(iree_hal_local_local PRIVATE -Wno-error=format -Wno-error=char-subscripts)
target_compile_options(iree_hal_local_executable_library_util PRIVATE -Wno-error=format -Wno-error=char-subscripts)
target_compile_options(iree_hal_local_executable_plugin_manager PRIVATE -Wno-error=format -Wno-error=char-subscripts)
target_compile_options(iree_hal_local_elf_arch PRIVATE -Wno-error=format -Wno-error=char-subscripts)
target_compile_options(iree_hal_local_elf_elf_module PRIVATE -Wno-error=format -Wno-error=char-subscripts)
target_compile_options(iree_hal_local_loaders_embedded_elf_loader PRIVATE -Wno-error=format -Wno-error=char-subscripts)
target_compile_options(iree_modules_hal_utils_buffer_diagnostics PRIVATE -Wno-error=format -Wno-error=char-subscripts)
target_compile_options(iree_modules_hal_hal PRIVATE -Wno-error=format -Wno-error=char-subscripts)
target_compile_options(iree_vm_bytecode_module PRIVATE -Wno-error=format -Wno-error=char-subscripts)
target_compile_options(iree_base_loop_sync PRIVATE -Wno-error=format -Wno-error=char-subscripts)
target_compile_options(iree_hal_local_loaders_static_library_loader PRIVATE -Wno-error=format -Wno-error=char-subscripts)
target_compile_options(iree_io_stream PRIVATE -Wno-error=format -Wno-error=char-subscripts)
target_compile_options(iree_io_formats_gguf_gguf PRIVATE -Wno-error=format)
target_compile_options(iree_io_formats_irpa_irpa PRIVATE -Wno-error=format)
target_compile_options(iree_modules_hal_inline_inline PRIVATE -Wno-error=format)
target_compile_options(iree_modules_io_parameters_parameters PRIVATE -Wno-error=format)
target_compile_options(iree_io_formats_safetensors_safetensors PRIVATE -Wno-error=char-subscripts)
#TODO: replace no-err with: "-DIREE_DEVICE_SIZE_T=uint32_t" "-DPRIdsz=PRIu32"
# add_compile_options("foo")
# add_definitions("-include iree_platform_overrides.h")
# SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -foobar")
