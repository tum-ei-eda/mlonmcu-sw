IF(CMSISNN)
    IF(NOT CMSIS_DIR)
        MESSAGE(FATAL_ERROR "Missing value: CMSIS_DIR")
    ENDIF()

    IF(NOT CMSISNN_DIR)
        MESSAGE(FATAL_ERROR "Missing value: CMSISNN_DIR")
    ENDIF()

    IF(NOT ARM_MVEI)
        SET(USE_MVEI OFF)
    ELSE()
        SET(USE_MVEI ON)
    ENDIF()

    IF(NOT ARM_DSP)
        SET(USE_DSP OFF)
    ELSE()
        SET(USE_DSP ON)
    ENDIF()

    SET(BUILD_FLAGS "")
    # IF(USE_MVEI) SET(BUILD_FLAGS "${BUILD_FLAGS} -D__ARM_FEATURE_MVE=1 -DARM_MATH_MVEI=1") ENDIF() IF(USE_DSP)
    # SET(BUILD_FLAGS "${BUILD_FLAGS} -D__ARM_FEATURE_DSP=1 -DARM_MATH_DSP=1") ENDIF()
    IF(RISCV_ARCH)
        SET(BUILD_FLAGS "${BUILD_FLAGS} -march=${RISCV_ARCH}")
    ENDIF()
    IF(RISCV_ABI)
        SET(BUILD_FLAGS "${BUILD_FLAGS} -mabi=${RISCV_ABI}")
    ENDIF()

    SET(CMSISNN_INCLUDE_DIRS
                             ${CMSISNN_DIR}
                             ${CMSISNN_DIR}/Include
                             ${CMSIS_DIR}/CMSIS/Core/Include
                             # ${CMSISNN_DIR}/CMSIS/NN/Include
                             # ${CMSISNN_DIR}/CMSIS/DSP/Include
    )

    # TODO: propagarting all toolchain specific vars does not scale well
    SET(ARGS "")

    FOREACH(X ${TC_VARS};CMAKE_TRY_COMPILE_TARGET_TYPE)
        SET(ARGS "${ARGS} -D${X}=\"${${X}}\"")
    ENDFOREACH()

    separate_arguments(ARGS UNIX_COMMAND "${ARGS}")

    INCLUDE(ExternalProject)
    EXTERNALPROJECT_ADD(
        cmsisnn
        PREFIX cmsisnn
        # SOURCE_DIR ${CMSISNN_DIR}/CMSIS/NN/
        SOURCE_DIR ${CMSISNN_DIR}/
        CMAKE_ARGS -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
                   -DCMAKE_C_FLAGS:STRING=${BUILD_FLAGS}
                   -DCMAKE_CXX_FLAGS:STRING=${BUILD_FLAGS}
                   -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
                   -DTC_PREFIX=${TC_PREFIX}
                   -DEXE_EXT=${EXE_EXT}
                   -DARM_CPU=${ARM_CPU}
                   -DARM_FLOAT_ABI=${ARM_FLOAT_ABI}
                   -DARM_FPU=${ARM_FPU}
                   -DRISCV_ARCH=${RISCV_ARCH}
                   -DRISCV_ABI=${RISCV_ABI}
                   -DCMSIS_PATH=${CMSIS_DIR}
                   ${ARGS}
        BUILD_COMMAND "${CMAKE_COMMAND}" --build . -j ${SUBPROJECT_THREADS}
        INSTALL_COMMAND ""
    )

    EXTERNALPROJECT_GET_PROPERTY(cmsisnn BINARY_DIR)
    SET(CMSISNN_LIB ${BINARY_DIR}/libcmsis-nn.a)

    # TFLite integration
    IF(TFLM_OPTIMIZED_KERNEL_LIB)
        LIST(APPEND TFLM_OPTIMIZED_KERNEL_LIB ${CMSISNN_LIB})
    ELSE()
        SET(TFLM_OPTIMIZED_KERNEL_LIB ${CMSISNN_LIB})
    ENDIF()

    IF(TFLM_OPTIMIZED_KERNEL_INCLUDE_DIR)
        LIST(APPEND TFLM_OPTIMIZED_KERNEL_INCLUDE_DIR ${CMSISNN_INCLUDE_DIRS})
    ELSE()
        SET(TFLM_OPTIMIZED_KERNEL_INCLUDE_DIR ${CMSISNN_INCLUDE_DIRS})
    ENDIF()

    IF(TFLM_OPTIMIZED_KERNEL_DEPS)
        LIST(APPEND TFLM_OPTIMIZED_KERNEL_DEPS cmsisnn)
    ELSE()
        SET(TFLM_OPTIMIZED_KERNEL_DEPS cmsisnn)
    ENDIF()

    # TVM integration
    IF(TVM_EXTRA_LIBS)
        LIST(APPEND TVM_EXTRA_LIBS ${CMSISNN_LIB})
    ELSE()
        SET(TVM_EXTRA_LIBS ${CMSISNN_LIB})
    ENDIF()

    IF(TVM_EXTRA_INCS)
        LIST(APPEND TVM_EXTRA_INCS ${CMSISNN_INCLUDE_DIRS})
    ELSE()
        SET(TVM_EXTRA_INCS ${CMSISNN_INCLUDE_DIRS})
    ENDIF()

    IF(TVM_EXTRA_DEPS)
        LIST(APPEND TVM_EXTRA_DEPS cmsisnn)
    ELSE()
        SET(TVM_EXTRA_DEPS cmsisnn)
    ENDIF()
ENDIF()
