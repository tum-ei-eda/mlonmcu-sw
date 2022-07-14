CMAKE_MINIMUM_REQUIRED(VERSION 3.13 FATAL_ERROR)

SET(TARGET_SYSTEM
    "host_x86"
    CACHE STRING "Specify which toolchain to use."
)
SET_PROPERTY(CACHE TARGET_SYSTEM PROPERTY STRINGS host_x86 etiss_pulpino generic_riscv corstone300)

# Choose which toolchain you want to use, either GCC or LLVM (or x86 for native build)
SET(TOOLCHAIN
    "gcc"
    CACHE STRING "Specify which toolchain to use."
)
SET_PROPERTY(CACHE TOOLCHAIN PROPERTY STRINGS gcc llvm)

SET(MLONMCU_BACKEND
    ""
    CACHE STRING "Specify which backend to use."
)
SET_PROPERTY(CACHE MLONMCU_BACKEND PROPERTY STRINGS tflmc tflmi tvmaot tvmrt tvmcg)

SET(MLONMCU_FRAMEWORK
    ""
    CACHE STRING "Specify which backend to use."
)
SET_PROPERTY(CACHE MLONMCU_FRAMEWORK PROPERTY STRINGS tflm tvm)

SET(OPTIMIZE
    "s"
    CACHE STRING "Specify compiler optimization level should be used in release mode."
)
SET_PROPERTY(CACHE MLONMCU_FRAMEWORK PROPERTY STRINGS tflm tvm)

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
    -O${OPTIMIZE} \
    -ffunction-sections \
    -fdata-sections \
    -fno-rtti \
    -fno-exceptions \
    -fno-threadsafe-statics \
"
)
SET(CMAKE_C_FLAGS_RELEASE
    "${CMAKE_C_FLAGS_RELEASE} \
    -O${OPTIMIZE} \
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

# TODO: pass list of features dynamically?
IF(CMSISNN)
    INCLUDE(features/cmsisnn)
ENDIF()

IF(MURISCVNN)
    INCLUDE(features/muriscvnn)
ENDIF()

INCLUDE(backends/${MLONMCU_BACKEND})
INCLUDE(frameworks/${MLONMCU_FRAMEWORK})

IF(TF_DIR)
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
