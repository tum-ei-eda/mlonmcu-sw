IF(NOT MURISCVNN_DIR)
    MESSAGE(FATAL_ERROR "Missing value: MURISCVNN_DIR")
ENDIF()

MESSAGE(STATUS "MURISCVNN_DIR=${MURISCVNN_DIR}")
MESSAGE(STATUS "MURISCVNN_VEXT=${MURISCVNN_VEXT}")
MESSAGE(STATUS "MURISCVNN_PEXT=${MURISCVNN_PEXT}")
MESSAGE(STATUS "TC_PREFIX=${TC_PREFIX}")
MESSAGE(STATUS "EXE_EXT=${EXE_EXT}")

IF(NOT RISCV_VEXT)
    SET(USE_VEXT OFF)
ELSE()
    SET(USE_VEXT ON)
ENDIF()

IF(NOT RISCV_PEXT)
    SET(USE_PEXT OFF)
ELSE()
    SET(USE_PEXT ON)
ENDIF()

IF(NOT MURISCVNN_TOOLCHAIN)
    SET(MURISCVVN_TOOLCHAIN GCC)
    # SET(MURISCVVN_TOOLCHAIN NONE)
ENDIF()

SET(MURISCVNN_INCLUDE_DIRS
    ${MURISCVNN_DIR}/Include
    ${MURISCVNN_DIR}/Include/CMSIS/NN/Include
)

include(ExternalProject)
ExternalProject_Add(muriscvnn
        PREFIX muriscvnn
        SOURCE_DIR ${MURISCVNN_DIR}
        CMAKE_ARGS
          -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
          -DUSE_VEXT=${USE_VEXT}
          -DUSE_PEXT=${USE_PEXT}
          -DTOOLCHAIN=${MURISCVNN_TOOLCHAIN}
          -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
          -DENABLE_TESTS=OFF
          -DTC_PREFIX=${TC_PREFIX}
          -DEXE_EXT=${EXE_EXT}
        BUILD_COMMAND "${CMAKE_COMMAND}" --build .
        INSTALL_COMMAND ""
)

ExternalProject_Get_Property(muriscvnn BINARY_DIR)
# SET(MURISCVNN_LIB ${CMAKE_BINARY_DIR}/${BINARY_DIR}/Source/libmuriscv_nn.a)
SET(MURISCVNN_LIB ${BINARY_DIR}/Source/libmuriscv_nn.a)
MESSAGE(STATUS "MURISCVNN_LIB=${MURISCVNN_LIB}")

# TFLite integration
IF(TFLM_OPTIMIZED_KERNEL_LIB)
    LIST(APPEND TFLM_OPTIMIZED_KERNEL_LIB ${MURISCVNN_LIB})
ELSE()
    SET(TFLM_OPTIMIZED_KERNEL_LIB ${MURISCVNN_LIB})
ENDIF()

IF(TFLM_OPTIMIZED_KERNEL_INCLUDE_DIR)
    LIST(APPEND TFLM_OPTIMIZED_KERNEL_INCLUDE_DIR ${MURISCVNN_INCLUDE_DIRS})
ELSE()
    SET(TFLM_OPTIMIZED_KERNEL_INCLUDE_DIR ${MURISCVNN_INCLUDE_DIRS})
ENDIF()

IF(TFLM_OPTIMIZED_KERNEL_DEPS)
    LIST(APPEND TFLM_OPTIMIZED_KERNEL_DEPS muriscvnn)
ELSE()
    SET(TFLM_OPTIMIZED_KERNEL_DEPS muriscvnn)
ENDIF()

# TVM integration
IF(TVM_EXTRA_LIBS)
    LIST(APPEND TVM_EXTRA_LIBS ${MURISCVNN_LIB})
ELSE()
    SET(TVM_EXTRA_LIBS ${MURISCVNN_LIB})
ENDIF()

IF(TVM_EXTRA_INCS)
    LIST(APPEND TVM_EXTRA_INCS ${MURISCVNN_INCLUDE_DIRS})
ELSE()
    SET(TVM_EXTRA_INCS ${MURISCVNN_INCLUDE_DIRS})
ENDIF()

IF(TVM_EXTRA_DEPS)
    LIST(APPEND TVM_EXTRA_DEPS muriscvnn)
ELSE()
    SET(TVM_EXTRA_DEPS muriscvnn)
ENDIF()
