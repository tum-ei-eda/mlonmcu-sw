CMAKE_MINIMUM_REQUIRED(VERSION 3.13 FATAL_ERROR)

SET(TARGET_SYSTEM
    "etiss_pulpino"
    CACHE STRING "The target system defined in ChooseTarget.cmake"
)

SET(ENABLE_LTO
    OFF
    CACHE BOOL "Whether to enable link-time optimization"
)

SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
INCLUDE(ChooseTarget)
INCLUDE(AddAllSubdirs)

PROJECT(ml_on_mcu_targetsw)

ENABLE_TESTING()

IF(NOT CMAKE_BUILD_TYPE)
    SET(CMAKE_BUILD_TYPE Release)
ENDIF()

SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

SET(CMAKE_CXX_STANDARD 14)
SET(CMAKE_CXX_STANDARD_REQUIRED ON)

SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -D_DEBUG")
SET(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -D_DEBUG")
SET(CMAKE_CXX_FLAGS_RELEASE
    "${CMAKE_CXX_FLAGS_RELEASE} \
    -Os \
    -ffunction-sections \
    -fdata-sections \
    -fno-rtti \
    -fno-exceptions \
    -fno-threadsafe-statics \
"
)
SET(CMAKE_C_FLAGS_RELEASE
    "${CMAKE_C_FLAGS_RELEASE} \
    -Os \
    -ffunction-sections \
    -fdata-sections \
"
)
SET(CMAKE_EXE_LINKER_FLAGS_RELEASE
    "${CMAKE_EXE_LINKER_FLAGS} \
    -Xlinker --gc-sections \
    -Xlinker -Map=linker.map \
    -Xlinker --cref \
"
)
IF(ENABLE_LTO)
    SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -flto -ffat-lto-objects")
    SET(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -flto -ffat-lto-objects")
    SET(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS} -Xlinker -flto")
ENDIF()

IF(TF_SRC)
    INCLUDE(LinkTFLite)
ENDIF()
IF(TVM_DIR)
    INCLUDE(LinkTVM)
ENDIF()

ADD_SUBDIRECTORY(lib)
ADD_SUBDIRECTORY(generic)
IF(RISCV_NN)
    ADD_SUBDIRECTORY(riscv_nn)
ENDIF()

IF(NOT SRC_DIR)
    MESSAGE(FATAL_ERROR "The variable SRC_DIR is not set")
ENDIF()

IF(EXISTS ${OUTPUT_DIR}/tflm_src)
    ADD_SUBDIRECTORY(tflite)
ELSE()
    MESSAGE(STATUS "Skipping 'tflite' because ${OUTPUT_DIR}/tflm_src does not exist...")
ENDIF()

IF(EXISTS ${OUTPUT_DIR}/tvm_src)
    ADD_SUBDIRECTORY(tvm)
ELSE()
    MESSAGE(STATUS "Skipping 'tvm' because ${OUTPUT_DIR}/tvm_src does not exist...")
ENDIF()
