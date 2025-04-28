IF(NOT SRC_DIR)
    MESSAGE(FATAL_ERROR "The variable SRC_DIR is not set")
ENDIF()
SET(IREE_EMITC
    OFF
    CACHE BOOL "Whether to use emitc mode for iree."
)
SET(IREE_INLINE_HAL
    OFF
    CACHE BOOL "TODO."
)
SET(IREE_LOADER_HAL
    OFF
    CACHE BOOL "TODO."
)
SET(IREE_VMVX  # TODO: get via backend?
    OFF
    CACHE BOOL "TODO."
)

MESSAGE(STATUS "IREE_EMITC=${IREE_EMITC}")

# set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# TODO: get IDENTIFIER

SET(EXTRA_SRC ml_interface_iree.c)

FILE(GLOB IREE_SRCS ${SRC_DIR}/*.c)
FILE(GLOB IREE_OBJS ${SRC_DIR}/*.o)

# IF(${GLOBAL_ISEL})
# target_compile_options(tvm_extension PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:C>:-mllvm -global-isel=1>")
# target_compile_options(tvm_extension PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:CXX>:-mllvm -global-isel=1>")
# ENDIF()

# SET(EXTRA_SRC ${EXTRA_SRC} ${IREE_SRCS} ${SRC_DIR}/iree_wrapper.c ${SRC_DIR}/device_embedded_sync.c)
SET(EXTRA_SRC ${EXTRA_SRC} ${IREE_SRCS} ${SRC_DIR}/iree_wrapper.c ${IREE_OBJS})
SET(EXTRA_INC ${SRC_DIR} ${IREE_INCS} ${IREE_SRC_DIR}/runtime/src)
#
SET(IREE_LIBS iree_runtime_unified)
IF(IREE_EMITC)
    # TODO: use correct target
    ADD_COMPILE_DEFINITIONS(EMITC_IMPLEMENTATION)
    LIST(APPEND IREE_LIBS iree_hal_local_loaders_static_library_loader)
ENDIF()
IF(IREE_INLINE_HAL)
    ADD_COMPILE_DEFINITIONS(BUILD_INLINE_HAL)
    LIST(APPEND IREE_LIBS iree_modules_hal_inline_inline)
ENDIF()
IF(IREE_LOADER_HAL)
    ADD_COMPILE_DEFINITIONS(BUILD_LOADER_HAL)
    LIST(APPEND IREE_LIBS iree_modules_hal_loader_loader)
    LIST(APPEND IREE_LIBS iree_modules_hal_inline_inline)
ENDIF()
IF(IREE_VMVX AND NOT IREE_INLINE_HAL)
    LIST(APPEND IREE_LIBS iree_hal_local_loaders_vmvx_module_loader)
ENDIF()
SET(EXTRA_LIBS ${IREE_LIBS})

# target_compile_options(iree_base_internal_time PRIVATE "-include${CMAKE_CURRENT_LIST_DIR}/iree_platform_overrides.h")
# target_compile_options(iree_base_base PRIVATE "-include${CMAKE_CURRENT_LIST_DIR}/iree_platform_overrides.h")
#
# FOREACH(ENTRY ${TVM_EXTRA_LIBS})
#     TARGET_LINK_LIBRARIES(tvm_extension PUBLIC ${ENTRY})
# ENDFOREACH()
# FOREACH(ENTRY ${TVM_EXTRA_INCS})
#     TARGET_INCLUDE_DIRECTORIES(tvm_extension PUBLIC ${ENTRY})
# ENDFOREACH()
# FOREACH(ENTRY ${TVM_EXTRA_DEPS})
#     ADD_DEPENDENCIES(tvm_extension ${TVM_EXTRA_DEPS})
# ENDFOREACH()
