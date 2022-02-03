SET(TF_SRC
    "/data/work/code/tensorflow"
    CACHE STRING "TensorFlow source directory"
)

SET(TFL_SRC ${TF_SRC}/tensorflow/lite)
SET(TFLM_SRC ${TFL_SRC}/micro)
SET(TFLD_SRC ${TFLM_SRC}/tools/make/downloads)

SET(TFLM_EXTRA_KERNEL_INCS "")

MESSAGE(STATUS "TFLM_OPTIMIZED_KERNEL=${TFLM_OPTIMIZED_KERNEL} TFLM_OPTIMIZED_KERNEL_LIB=${TFLM_OPTIMIZED_KERNEL_LIB} TFLM_OPTIMIZED_KERNEL_INCLUDE_DIR=${TFLM_OPTIMIZED_KERNEL_INCLUDE_DIR}")

IF(TFLM_OPTIMIZED_KERNEL)
    # Suboptimal but we do not want to hardcode every kernel which should be replaced...
    FILE(GLOB TFLM_EXTRA_KERNEL_SRCS ${TFLM_SRC}/kernels/${TFLM_OPTIMIZED_KERNEL}/*.cc)
    # LIST(APPEND TFLM_EXTRA_KERNEL_INCS ${TFLM_SRC}/kernels/${TFLM_OPTIMIZED_KERNEL}/)
    STRING(TOUPPER "${TFLM_OPTIMIZED_KERNEL}" TFLM_OPTIMIZED_KERNEL_UPPER)
ENDIF()

IF(TFLM_OPTIMIZED_KERNEL_LIB)
    SET(TFLM_EXTRA_KERNEL_LIB ${TFLM_OPTIMIZED_KERNEL_LIB})
ENDIF()

IF(TFLM_OPTIMIZED_KERNEL_INCLUDE_DIR)
    LIST(APPEND TFLM_EXTRA_KERNEL_INCS ${TFLM_OPTIMIZED_KERNEL_INCLUDE_DIR})
ENDIF()

SET(CUSTOM_QUANT_SRC ${TFL_SRC}/experimental/custom_quantization_util.cc)
IF(EXISTS ${CUSTOM_QUANT_SRC})
    SET(OPT_SRC ${CUSTOM_QUANT_SRC})
ENDIF()

SET(TFLM_REFERENCE_KERNEL_SRCS
    ${TFLM_SRC}/kernels/softmax.cc
    ${TFLM_SRC}/kernels/fully_connected.cc
    ${TFLM_SRC}/kernels/pooling.cc
    ${TFLM_SRC}/kernels/add.cc
    ${TFLM_SRC}/kernels/mul.cc
    ${TFLM_SRC}/kernels/conv.cc
    ${TFLM_SRC}/kernels/depthwise_conv.cc
    ${TFLM_SRC}/kernels/softmax.cc
    ${TFLM_SRC}/kernels/fully_connected.cc
    ${TFLM_SRC}/kernels/pooling.cc
    ${TFLM_SRC}/kernels/add.cc
    ${TFLM_SRC}/kernels/mul.cc
    ${TFLM_SRC}/kernels/conv.cc
    ${TFLM_SRC}/kernels/depthwise_conv.cc
    ${TFLM_SRC}/kernels/logical.cc
    ${TFLM_SRC}/kernels/logistic.cc
    ${TFLM_SRC}/kernels/svdf.cc
    ${TFLM_SRC}/kernels/concatenation.cc
    ${TFLM_SRC}/kernels/ceil.cc
    ${TFLM_SRC}/kernels/floor.cc
    ${TFLM_SRC}/kernels/prelu.cc
    ${TFLM_SRC}/kernels/neg.cc
    ${TFLM_SRC}/kernels/elementwise.cc
    ${TFLM_SRC}/kernels/maximum_minimum.cc
    ${TFLM_SRC}/kernels/arg_min_max.cc
    ${TFLM_SRC}/kernels/reshape.cc
    ${TFLM_SRC}/kernels/comparisons.cc
    ${TFLM_SRC}/kernels/round.cc
    ${TFLM_SRC}/kernels/strided_slice.cc
    ${TFLM_SRC}/kernels/pack.cc
    ${TFLM_SRC}/kernels/pad.cc
    ${TFLM_SRC}/kernels/split.cc
    ${TFLM_SRC}/kernels/unpack.cc
    ${TFLM_SRC}/kernels/quantize.cc
    ${TFLM_SRC}/kernels/activations.cc
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
IF(EXISTS ${TFLM_SRC}/kernels/detection_postprocess.cc)
    LIST(APPEND TFLM_REFERENCE_KERNEL_SRCS ${TFLM_SRC}/kernels/detection_postprocess.cc)
ENDIF()

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

# This file only exists in newer versions of TF
IF(EXISTS ${TFL_SRC}/schema/schema_utils.cc)
    LIST(APPEND OPT_SRC ${TFL_SRC}/schema/schema_utils.cc)
ENDIF()

ADD_LIBRARY(
    tflite STATIC
    # Not really needed?
    ${TFLM_SRC}/micro_error_reporter.cc
    ${TFLM_SRC}/debug_log.cc
    ${TFLM_SRC}/micro_string.cc
    # For reporter->Report
    ${TF_SRC}/tensorflow/lite/core/api/error_reporter.cc
    # Kernels
    ${TFLM_REFERENCE_KERNEL_SRCS}
    ${TFLM_EXTRA_KERNEL_SRCS}
    # Kernel deps
    ${TFLM_SRC}/kernels/kernel_util.cc
    ${TFLM_SRC}/all_ops_resolver.cc
    ${TFLM_SRC}/micro_utils.cc
    ${TFL_SRC}/kernels/internal/quantization_util.cc
    ${TFL_SRC}/kernels/kernel_util.cc
    ${TFL_SRC}/c/common.c
    ${TFLM_SRC}/micro_interpreter.cc
    ${TFLM_SRC}/micro_allocator.cc
    ${TFLM_SRC}/simple_memory_allocator.cc
    ${TFLM_SRC}/memory_helpers.cc
    ${TFLM_SRC}/memory_planner/greedy_memory_planner.cc
    ${TFL_SRC}/core/api/tensor_utils.cc
    ${TFL_SRC}/core/api/flatbuffer_conversions.cc
    ${TFL_SRC}/core/api/op_resolver.cc
    ${OPT_SRC}
)

IF(TFLM_EXTRA_KERNEL_LIB)
    TARGET_LINK_LIBRARIES(tflite PUBLIC ${TFLM_EXTRA_KERNEL_LIB})
ENDIF()

# cmake-format: off
TARGET_INCLUDE_DIRECTORIES(tflite PUBLIC
    ${TF_SRC}
    ${TFLD_SRC}/flatbuffers/include
    ${TFLD_SRC}/gemmlowp
    ${TFLD_SRC}/ruy
    ${TFLM_EXTRA_KERNEL_INCS}
)
# cmake-format: on

# cmake-format: off
TARGET_COMPILE_DEFINITIONS(tflite PUBLIC
    TF_LITE_USE_GLOBAL_CMATH_FUNCTIONS
    TF_LITE_USE_GLOBAL_MAX
    TF_LITE_USE_GLOBAL_MIN
    TF_LITE_STATIC_MEMORY
    TFLITE_EMULATE_FLOAT
    "$<$<CONFIG:RELEASE>:TF_LITE_STRIP_ERROR_STRINGS>"
    ${TFLM_OPTIMIZED_KERNEL_UPPER}
)
# cmake-format: on
