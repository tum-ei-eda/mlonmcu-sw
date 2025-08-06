SET(TF_DIR
    "/data/work/code/tensorflow"
    CACHE PATH "TensorFlow source directory"
)
SET(TFLM_GENERATE_TREE
    OFF
    CACHE BOOL ""
)
SET(CFU_ACCELERATE
    OFF
    CACHE BOOL "TODO"
)
SET(CFU_CONV2D_IDX_INIT
    ""
    CACHE STRING "TODO"
)
set(TFLM_OVERRIDE "" CACHE PATH "Optional path to directory with TFLM override sources")

IF(TFLM_GENERATE_TREE)
    # TODO: add custom command and dependency
    SET(TFLM_TREE ${CMAKE_CURRENT_BINARY_DIR}/tflite-micro)
    SET(EXTRA_ARGS)
    if(EXISTS "${TFLM_TREE}/tensorflow/lite/micro/kernels/micro_ops.h")
        message(STATUS "TFLM tree already exists")
    else()
        message(STATUS "Generating TFLM tree")
        IF(TFLM_OPTIMIZED_KERNEL)
            SET(EXTRA_ARGS "${EXTRA_ARGS} --makefile_options=OPTIMIZED_KERNEL_DIR=${TFLM_OPTIMIZED_KERNEL}")
        ENDIF()

        # ADD_CUSTOM_COMMAND(
        #     OUTPUT ${TFLM_TREE}/tensorflow/lite/micro/kernels/micro_ops.h  # Dummy output to track freshness
        #     OUTPUT ${TFLM_TREE}/tensorflow/lite/micro/kernels/fully_connected.cc
        #     COMMAND ${CMAKE_COMMAND} -E make_directory ${TFLM_TREE}
        #     COMMAND ${CMAKE_COMMAND} -E env PYTHONPATH=${TF_DIR} VERBOSE=0 GNUMAKEFLAGS=--no-print-directory MAKEFLAGS=--no-print-directory
        #             python3 ${TF_DIR}/tensorflow/lite/micro/tools/project_generation/create_tflm_tree.py
        #             ${TFLM_TREE}
        #             ${EXTRA_ARGS}
        #     WORKING_DIRECTORY ${TF_DIR}
        #     DEPENDS ${TF_DIR}/tensorflow/lite/micro/tools/project_generation/create_tflm_tree.py
        #     COMMENT "Generating TFLM source tree..."
        #     VERBATIM
        # )
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E make_directory ${TFLM_TREE}
            COMMAND ${CMAKE_COMMAND} -E env PYTHONPATH=${TF_DIR} VERBOSE=0 GNUMAKEFLAGS=--no-print-directory MAKEFLAGS=--no-print-directory
                    python3 ${TF_DIR}/tensorflow/lite/micro/tools/project_generation/create_tflm_tree.py
                    ${TFLM_TREE}
                    ${EXTRA_ARGS}
            WORKING_DIRECTORY ${TF_DIR}
            RESULT_VARIABLE _gen_result
        )

        if(NOT _gen_result EQUAL 0)
          message(FATAL_ERROR "Failed to generate TFLM tree!")
        endif()

        if(NOT TFLM_OVERRIDE STREQUAL "")
          if(EXISTS "${TFLM_OVERRIDE}")
            message(STATUS "TFLM_OVERRIDE is set: ${TFLM_OVERRIDE}")
            file(GLOB_RECURSE override_files RELATIVE "${TFLM_OVERRIDE}" "${TFLM_OVERRIDE}/*")

            foreach(file IN LISTS override_files)
              set(src "${TFLM_OVERRIDE}/${file}")
              set(dst "${TFLM_TREE}/${file}")

              # Create destination directory if needed
              get_filename_component(dst_dir "${dst}" DIRECTORY)
              file(MAKE_DIRECTORY "${dst_dir}")

              # Copy file only if it differs (optional optimization)
              configure_file("${src}" "${dst}" COPYONLY)
            endforeach()

            message(STATUS "TFLM overrides copied to: ${TFLM_TREE}")
          else()
            message(STATUS "No valid TFLM_OVERRIDE provided.")
          endif()
        endif()

        # ADD_CUSTOM_TARGET(generate_tflm_tree
        #     DEPENDS ${TFLM_TREE}/tensorflow/lite/micro/kernels/micro_ops.h
        # )
        endif()

    SET(TF_DIR ${TFLM_TREE})
ELSE()
    IF(TFLM_OVERRIDE)
        MESSAGE(FATAL_ERROR "TFLM_OVERRIDE requires TFLM_GENERATE_TREE")
    ENDIF()
ENDIF()

SET(TFL_SRC ${TF_DIR}/tensorflow/lite)
SET(TFLM_SRC ${TFL_SRC}/micro)
SET(TFLD_SRC ${TFLM_SRC}/tools/make/downloads)


SET(TFLM_EXTRA_KERNEL_LIBS "")
SET(TFLM_EXTRA_KERNEL_INCS "")

IF(TFLM_OPTIMIZED_KERNEL)
    # Suboptimal but we do not want to hardcode every kernel which should be replaced...
    FILE(GLOB TFLM_EXTRA_KERNEL_SRCS ${TFLM_SRC}/kernels/${TFLM_OPTIMIZED_KERNEL}/*.cc)
    # LIST(APPEND TFLM_EXTRA_KERNEL_INCS ${TFLM_SRC}/kernels/${TFLM_OPTIMIZED_KERNEL}/)
    STRING(TOUPPER "${TFLM_OPTIMIZED_KERNEL}" TFLM_OPTIMIZED_KERNEL_UPPER)
ENDIF()

IF(TFLM_OPTIMIZED_KERNEL_LIB)
    LIST(APPEND TFLM_EXTRA_KERNEL_LIBS ${TFLM_OPTIMIZED_KERNEL_LIB})
ENDIF()

IF(TFLM_OPTIMIZED_KERNEL_INCLUDE_DIR)
    LIST(APPEND TFLM_EXTRA_KERNEL_INCS ${TFLM_OPTIMIZED_KERNEL_INCLUDE_DIR})
ENDIF()

IF(TFLM_OPTIMIZED_KERNEL_DEPS)
    LIST(APPEND TFLM_EXTRA_KERNEL_DEPS ${TFLM_OPTIMIZED_KERNEL_DEPS})
ENDIF()

IF(TFLM_OPTIMIZED_KERNEL_DEFS)
    LIST(APPEND TFLM_EXTRA_KERNEL_DEFS ${TFLM_OPTIMIZED_KERNEL_DEFS})
ENDIF()

SET(CUSTOM_QUANT_SRC ${TFL_SRC}/experimental/custom_quantization_util.cc)
IF(EXISTS ${CUSTOM_QUANT_SRC})
    SET(OPT_SRC ${CUSTOM_QUANT_SRC})
ENDIF()

SET(TFLM_REFERENCE_KERNEL_SRCS
    ${TFLM_SRC}/kernels/softmax.cc
    ${TFLM_SRC}/kernels/fully_connected.cc
    ${TFLM_SRC}/kernels/pooling.cc
    ${TFLM_SRC}/kernels/mul.cc
    ${TFLM_SRC}/kernels/mul_common.cc
    ${TFLM_SRC}/kernels/conv.cc
    ${TFLM_SRC}/kernels/depthwise_conv.cc
    ${TFLM_SRC}/kernels/softmax.cc
    ${TFLM_SRC}/kernels/fully_connected.cc
    ${TFLM_SRC}/kernels/pooling.cc
    ${TFLM_SRC}/kernels/add.cc
    ${TFLM_SRC}/kernels/add_n.cc
    ${TFLM_SRC}/kernels/mul.cc
    ${TFLM_SRC}/kernels/conv.cc
    ${TFLM_SRC}/kernels/depthwise_conv.cc
    ${TFLM_SRC}/kernels/logical.cc
    ${TFLM_SRC}/kernels/logistic.cc
    ${TFLM_SRC}/kernels/svdf.cc
    ${TFLM_SRC}/kernels/unidirectional_sequence_lstm.cc
    ${TFLM_SRC}/kernels/lstm_eval.cc
    ${TFLM_SRC}/kernels/lstm_eval_common.cc
    ${TFLM_SRC}/kernels/concatenation.cc
    ${TFLM_SRC}/kernels/ceil.cc
    ${TFLM_SRC}/kernels/floor.cc
    ${TFLM_SRC}/kernels/prelu.cc
    ${TFLM_SRC}/kernels/neg.cc
    ${TFLM_SRC}/kernels/elementwise.cc
    ${TFLM_SRC}/kernels/maximum_minimum.cc
    ${TFLM_SRC}/kernels/arg_min_max.cc
    ${TFLM_SRC}/kernels/shape.cc
    ${TFLM_SRC}/kernels/reshape.cc
    ${TFLM_SRC}/kernels/reshape_common.cc
    ${TFLM_SRC}/kernels/expand_dims.cc
    ${TFLM_SRC}/kernels/leaky_relu.cc
    ${TFLM_SRC}/kernels/leaky_relu_common.cc
    ${TFLM_SRC}/kernels/exp.cc
    ${TFLM_SRC}/kernels/broadcast_args.cc
    ${TFLM_SRC}/kernels/fill.cc
    ${TFLM_SRC}/kernels/comparisons.cc
    ${TFLM_SRC}/kernels/round.cc
    ${TFLM_SRC}/kernels/strided_slice.cc
    ${TFLM_SRC}/kernels/pack.cc
    ${TFLM_SRC}/kernels/pad.cc
    ${TFLM_SRC}/kernels/split.cc
    ${TFLM_SRC}/kernels/unpack.cc
    ${TFLM_SRC}/kernels/quantize.cc
    ${TFLM_SRC}/kernels/activations.cc
    ${TFLM_SRC}/kernels/activations_common.cc
    ${TFLM_SRC}/kernels/dequantize.cc
    ${TFLM_SRC}/kernels/reduce.cc
    ${TFLM_SRC}/kernels/sub.cc
    ${TFLM_SRC}/kernels/resize_nearest_neighbor.cc
    ${TFLM_SRC}/kernels/l2norm.cc
    ${TFLM_SRC}/kernels/circular_buffer.cc
    ${TFLM_SRC}/kernels/ethosu.cc
    ${TFLM_SRC}/kernels/tanh.cc
)

# This files only exists in newer versions of TF
IF(EXISTS ${TFLM_SRC}/kernels/conv_common.cc)
    LIST(APPEND TFLM_REFERENCE_KERNEL_SRCS ${TFLM_SRC}/kernels/conv_common.cc)
ENDIF()
IF(EXISTS ${TFLM_SRC}/kernels/depthwise_conv_common.cc)
    LIST(APPEND TFLM_REFERENCE_KERNEL_SRCS ${TFLM_SRC}/kernels/depthwise_conv_common.cc)
ENDIF()
IF(EXISTS ${TFLM_SRC}/kernels/fully_connected_common.cc)
    LIST(APPEND TFLM_REFERENCE_KERNEL_SRCS ${TFLM_SRC}/kernels/fully_connected_common.cc)
ENDIF()
IF(EXISTS ${TFLM_SRC}/kernels/quantize_common.cc)
    LIST(APPEND TFLM_REFERENCE_KERNEL_SRCS ${TFLM_SRC}/kernels/quantize_common.cc)
ENDIF()
IF(EXISTS ${TFLM_SRC}/kernels/softmax_common.cc)
    LIST(APPEND TFLM_REFERENCE_KERNEL_SRCS ${TFLM_SRC}/kernels/softmax_common.cc)
ENDIF()
IF(EXISTS ${TFLM_SRC}/kernels/svdf_common.cc)
    LIST(APPEND TFLM_REFERENCE_KERNEL_SRCS ${TFLM_SRC}/kernels/svdf_common.cc)
ENDIF()
IF(EXISTS ${TFLM_SRC}/kernels/pooling_common.cc)
    LIST(APPEND TFLM_REFERENCE_KERNEL_SRCS ${TFLM_SRC}/kernels/pooling_common.cc)
ENDIF()
IF(EXISTS ${TFLM_SRC}/kernels/add_common.cc)
    LIST(APPEND TFLM_REFERENCE_KERNEL_SRCS ${TFLM_SRC}/kernels/add_common.cc)
ENDIF()
IF(EXISTS ${TFLM_SRC}/kernels/dequantize_common.cc)
    LIST(APPEND TFLM_REFERENCE_KERNEL_SRCS ${TFLM_SRC}/kernels/dequantize_common.cc)
ENDIF()
IF(EXISTS ${TFLM_SRC}/kernels/detection_postprocess.cc)
    LIST(APPEND TFLM_REFERENCE_KERNEL_SRCS ${TFLM_SRC}/kernels/detection_postprocess.cc)
ENDIF()

IF(NOT TFLM_GENERATE_TREE)
    FOREACH(src ${TFLM_EXTRA_KERNEL_SRCS})
        GET_FILENAME_COMPONENT(src_name ${src} NAME)
        IF(${src_name} MATCHES ".*_test.*")
            LIST(REMOVE_ITEM TFLM_EXTRA_KERNEL_SRCS ${src})
        ELSE()
            SET(src_path "${TFLM_SRC}/kernels/${src_name}")
            LIST(FIND TFLM_REFERENCE_KERNEL_SRCS ${src_path} TFLM_KERNEL_SRCS_FOUND_INDEX)
            IF(${TFLM_KERNEL_SRCS_FOUND_INDEX} GREATER_EQUAL 0)
                MESSAGE(STATUS "Replacing TFLM version of ${src_name} by optimized variant...")
                LIST(REMOVE_ITEM TFLM_REFERENCE_KERNEL_SRCS ${src_path})
            ENDIF()
        ENDIF()
    ENDFOREACH()
ENDIF()

IF(NOT TFLM_GENERATE_TREE)
    SET(TFLM_SRCS
        # Not really needed?
        ${TFLM_SRC}/micro_error_reporter.cc
        ${TFLM_SRC}/debug_log.cc
        ${TFLM_SRC}/micro_string.cc
        # For reporter->Report
        ${TF_DIR}/tensorflow/lite/core/api/error_reporter.cc
        # Kernel deps
        ${TFLM_SRC}/kernels/kernel_util.cc
        ${TFLM_SRC}/all_ops_resolver.cc
        ${TFLM_SRC}/micro_utils.cc
        ${TFLM_SRC}/micro_log.cc
        ${TFL_SRC}/kernels/internal/quantization_util.cc
        ${TFL_SRC}/kernels/kernel_util.cc
        ${TFL_SRC}/kernels/internal/tensor_ctypes.cc
        ${TFL_SRC}/kernels/internal/portable_tensor_utils.cc
        # Kernels
        ${TFLM_REFERENCE_KERNEL_SRCS}
        ${TFLM_EXTRA_KERNEL_SRCS}
        ${TFLM_SRC}/micro_interpreter.cc
        ${TFLM_SRC}/micro_allocator.cc
        ${TFLM_SRC}/simple_memory_allocator.cc
        ${TFLM_SRC}/arena_allocator/simple_memory_allocator.cc
        ${TFLM_SRC}/micro_allocation_info.cc
        ${TFLM_SRC}/micro_resource_variable.cc
        ${TFLM_SRC}/arena_allocator/single_arena_buffer_allocator.cc
        ${TFLM_SRC}/arena_allocator/persistent_arena_buffer_allocator.cc
        ${TFLM_SRC}/arena_allocator/non_persistent_arena_buffer_allocator.cc
        ${TFLM_SRC}/memory_helpers.cc
        ${TFLM_SRC}/memory_planner/greedy_memory_planner.cc
        ${TFLM_SRC}/memory_planner/linear_memory_planner.cc
        ${TFLM_SRC}/tflite_bridge/flatbuffer_conversions_bridge.cc
        ${TFLM_SRC}/tflite_bridge/micro_error_reporter.cc
        ${TFL_SRC}/core/api/tensor_utils.cc
        ${TFL_SRC}/kernels/internal/tensor_utils.cc
        ${TFL_SRC}/kernels/internal/portable_tensor_utils.cc
        ${TFL_SRC}/kernels/internal/reference/portable_tensor_utils.cc
        ${TFL_SRC}/kernels/internal/common.cc
        ${TFL_SRC}/core/api/flatbuffer_conversions.cc
        ${TFL_SRC}/core/api/op_resolver.cc
        ${TFLM_SRC}/micro_op_resolver.cc
        ${TFLM_SRC}/tflite_bridge/flatbuffer_conversions_bridge.cc
        ${TFLM_SRC}/tflite_bridge/micro_error_reporter.cc
        ${TFL_SRC}/core/c/common.cc  # new
        ${TFL_SRC}/c/common.cc  # new
        ${TFL_SRC}/c/common.c  # old
        ${TFLM_SRC}/flatbuffer_utils.cc
        ${TFLM_SRC}/micro_graph.cc
        ${TFLM_SRC}/micro_interpreter_graph.cc
        ${TFLM_SRC}/micro_interpreter_context.cc
        ${TFLM_SRC}/micro_op_resolver.cc
        ${TFLM_SRC}/micro_context.cc
        ${TFL_SRC}/schema/schema_utils.cc
        ${TF_DIR}/tensorflow/compiler/mlir/lite/schema/schema_utils.cc
        ${OPT_SRC}
    )
ELSE()
    # Create dummy source file list initially
    # SET(TFLM_SRCS ${CMAKE_CURRENT_LIST_DIR}/dummy_placeholder.cc)

    # Include actual list only if tree was already generated (e.g. user manually ran it)
    # IF(EXISTS ${TFLM_TREE}/tensorflow/lite/micro/kernels/micro_ops.h)
    # INCLUDE(${CMAKE_CURRENT_BINARY_DIR}/tflm_sources.cmake)
    FILE(GLOB TFLM_SRCS CONFIGURE_DEPENDS ${TFLM_SRC}/*.cc ${TFLM_SRC}/kernels/*.cc ${TFLM_SRC}/kernels/*.cc ${TFLM_SRC}/memory_planner/*.cc ${TFLM_SRC}/arena_allocator/*.cc ${TFLM_SRC}/tflite_bridge/*.cc ${TFL_SRC}/core/c/*.cc ${TFL_SRC}/core/api/*.cc ${TF_DIR}/tensorflow/compiler/mlir/lite/schema/*.cc ${TFL_SRC}/kernels/internal/*.cc ${TFL_SRC}/kernels/*.cc)
    FOREACH(src ${TFLM_SRCS})
        GET_FILENAME_COMPONENT(src_name ${src} NAME)
        IF(${src_name} MATCHES ".*_test.*")
            LIST(REMOVE_ITEM TFLM_SRCS ${src})
        ENDIF()
    ENDFOREACH()
ENDIF()

# For backwards compatibility, we drop non-existance files here.
IF(NOT TFLM_GENERATE_TREE)
    FOREACH(src ${TFLM_SRCS})
        IF(NOT EXISTS ${src})
             LIST(REMOVE_ITEM TFLM_SRCS ${src})
        ENDIF()
    ENDFOREACH()
ENDIF()

COMMON_ADD_LIBRARY(
    tflm STATIC
    ${TFLM_SRCS}
)

IF(TFLM_EXTRA_KERNEL_LIBS)
    TARGET_LINK_LIBRARIES(tflm PUBLIC ${TFLM_EXTRA_KERNEL_LIBS})
ENDIF()
TARGET_LINK_LIBRARIES(tflm PUBLIC m)

IF(TFLM_OPTIMIZED_KERNEL_DEPS)
    ADD_DEPENDENCIES(tflm ${TFLM_OPTIMIZED_KERNEL_DEPS})
ENDIF()

# cmake-format: off
IF(NOT TFLM_GENERATE_TREE)
TARGET_INCLUDE_DIRECTORIES(tflm PUBLIC
    ${TF_DIR}
    ${TFLD_SRC}/flatbuffers/include
    ${TFLD_SRC}/gemmlowp
    ${TFLD_SRC}/ruy
    ${TFLM_EXTRA_KERNEL_INCS}
)
ELSE()
TARGET_INCLUDE_DIRECTORIES(tflm PUBLIC
    ${TF_DIR}
    ${TFLM_TREE}/third_party/flatbuffers/include
    ${TFLM_TREE}/third_party/gemmlowp
    ${TFLM_TREE}/third_party/ruy
    ${TFLM_EXTRA_KERNEL_INCS}
)
ENDIF()
# cmake-format: on

# cmake-format: off
TARGET_COMPILE_DEFINITIONS(tflm PUBLIC
    TF_LITE_USE_GLOBAL_CMATH_FUNCTIONS
    TF_LITE_USE_GLOBAL_MAX
    TF_LITE_USE_GLOBAL_MIN
    TF_LITE_STATIC_MEMORY
    TFLITE_EMULATE_FLOAT
    "$<$<CONFIG:RELEASE>:TF_LITE_STRIP_ERROR_STRINGS>"
    ${TFLM_OPTIMIZED_KERNEL_UPPER}
    ${TFLM_EXTRA_KERNEL_DEFS}
)
IF(CFU_ACCELERATE)
    # TARGET_COMPILE_DEFINITIONS(tflm PUBLIC CFU_ACCELERATE)
    TARGET_COMPILE_DEFINITIONS(tflm PUBLIC CONV_ACCELERATE)
    IF(NOT CFU_CONV2D_IDX_INIT STREQUAL "")
        TARGET_COMPILE_DEFINITIONS(tflm PUBLIC CFU_CONV2D_IDX_INIT=${CFU_CONV2D_IDX_INIT})
    ENDIF()
ENDIF()

# Workaround for the following issue which does not envolve patching the tflite-micro codebase:

# .../micro_error_reporter.cc: In function 'tflite::ErrorReporter* tflite::GetMicroErrorReporter()':
# .../micro_error_reporter.cc:58:76: error: 'static void tflite::MicroErrorReporter::operator delete(void*)' is private within this context
#    58 |     error_reporter_ = new (micro_error_reporter_buffer) MicroErrorReporter();
#       |                                                                            ^
# In file included from .../micro_error_reporter.h:21,
#                  from .../micro_error_reporter.cc:16:
# .../compatibility.h:27:8: note: declared private here
#    27 |   void operator delete(void* p) {}
#       |        ^~~~~~~~
# .../micro_error_reporter.h:51:3: note: in expansion of macro 'TF_LITE_REMOVE_VIRTUAL_DELETE'
#    51 |   TF_LITE_REMOVE_VIRTUAL_DELETE
#
# If disabling the exceptions has major disadvantages needs to be investigated.

TARGET_COMPILE_OPTIONS(tflm PUBLIC
    -fno-exceptions
)
# cmake-format: on

IF(${GLOBAL_ISEL})
target_compile_options(tflm PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:C>:-mllvm -global-isel=1>")
target_compile_options(tflm PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:CXX>:-mllvm -global-isel=1>")
ENDIF()

# IF(TFLM_GENERATE_TREE)
#     ADD_DEPENDENCIES(tflm generate_tflm_tree)
# ENDIF()
#
# add_custom_target(tflm_ready DEPENDS tflm)
