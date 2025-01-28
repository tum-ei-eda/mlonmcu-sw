CMAKE_MINIMUM_REQUIRED(VERSION 3.13 FATAL_ERROR)

SET(CMAKE_EXPORT_COMPILE_COMMANDS ON)

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

SET(OPTIMIZE
    "3"
    CACHE STRING "Specify compiler optimization level should be used in release mode."
)

SET(ENABLE_LTO
    OFF
    CACHE BOOL "Whether to enable link-time optimization."
)

SET(ENABLE_GC
    ON
    CACHE BOOL "Whether to enable garbage collection to eliminate unused code."
)

SET(PROTECT_STACK
    OFF
    CACHE BOOL "Whether to enable stack guards"
)
SET(SLIM_CPP
    ON
    CACHE BOOL "Disable assertions,... for more leightweight cpp code."
)

SET(SUBPROJECT_THREADS
    4
    CACHE STRING "Number of threads used for building subprojects."
)

SET(UNROLL_LOOPS
    "AUTO"
    CACHE STRING "Specify loop unrolling behavior."
)
SET_PROPERTY(CACHE UNROLL_LOOPS PROPERTY STRINGS AUTO ON OFF)

SET(EXTRA_C_FLAGS "" CACHE STRING "Additional C options.")
SET(EXTRA_CXX_FLAGS "" CACHE STRING "Additional C++ options.")
SET(EXTRA_ASM_FLAGS "" CACHE STRING "Additional ASM options.")
SET(EXTRA_LD_FLAGS "" CACHE STRING "Additional linker options.")


SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
INCLUDE(ChooseTarget)
INCLUDE(AddAllSubdirs)

INCLUDE(features/auto_vectorize)
INCLUDE(features/memgraph_llvm_cdfg)
INCLUDE(features/global_isel)
INCLUDE(features/llvm_basic_block_sections)

PROJECT(mlonmcu_sw)

ENABLE_TESTING()

IF(NOT CMAKE_BUILD_TYPE)
    SET(CMAKE_BUILD_TYPE Release)
ENDIF()

SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

SET(CMAKE_CXX_STANDARD 14)
SET(CMAKE_CXX_STANDARD_REQUIRED ON)

SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -D_DEBUG")
SET(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -D_DEBUG")
SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O${OPTIMIZE}")
SET(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -O${OPTIMIZE}")

SET(CMAKE_EXE_LINKER_FLAGS_RELEASE
    "${CMAKE_EXE_LINKER_FLAGS} \
    -Xlinker -Map=linker.map \
    -Xlinker --cref \
"
)
IF(${DEBUG_SYMBOLS})
    SET(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -g")
    SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -g")
ENDIF()
IF(ENABLE_GC)
    SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -ffunction-sections -fdata-sections")
    SET(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -ffunction-sections -fdata-sections")
    SET(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} -Xlinker --gc-sections")
ENDIF()
IF(ENABLE_LTO)
    SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -flto")
    SET(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -flto")
    IF(TOOLCHAIN STREQUAL "gcc")
        SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -ffat-lto-objects")
        SET(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -ffat-lto-objects")
    ENDIF()
    SET(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} -Xlinker -flto")
ENDIF()
IF(SLIM_CPP)
    SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -fno-rtti -fno-exceptions -fno-threadsafe-statics")
ENDIF()
IF(PROTECT_STACK)
    SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -fstack-protector-all")
    SET(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -fstack-protector-all")
    SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fstack-protector-all")
    SET(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -fstack-protector-all")
ENDIF()
IF(NOT "${UNROLL_LOOPS}" STREQUAL "AUTO")
    IF(UNROLL_LOOPS)
        SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -funroll-loops")
        SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -funroll-loops")
    ELSE()
        SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-unroll-loops")
        SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-unroll-loops")
    ENDIF()
ENDIF()
# SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -fno-asynchronous-unwind-tables -fno-unwind-tables")
# SET(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -fno-asynchronous-unwind-tables -fno-unwind-tables")
# SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fno-asynchronous-unwind-tables -fno-unwind-tables")
# SET(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -fno-asynchronous-unwind-tables -fno-unwind-tables")

# TODO: pass list of features dynamically?
INCLUDE(features/cmsisnn)
INCLUDE(features/muriscvnn)

foreach(X IN ITEMS ${EXTRA_C_FLAGS} ${FEATURE_EXTRA_C_FLAGS})
    add_compile_options("SHELL:$<$<COMPILE_LANGUAGE:C>:${X}>")
endforeach()
foreach(X IN ITEMS ${EXTRA_CXX_FLAGS} ${FEATURE_EXTRA_CXX_FLAGS})
    add_compile_options("SHELL:$<$<COMPILE_LANGUAGE:CXX>:${X}>")
endforeach()
foreach(X IN ITEMS ${EXTRA_ASM_FLAGS} ${FEATURE_EXTRA_ASM_FLAGS})
    add_compile_options("SHELL:$<$<COMPILE_LANGUAGE:ASM>:${X}>")
endforeach()
foreach(X IN ITEMS ${EXTRA_LD_FLAGS} ${FEATURE_EXTRA_LD_FLAGS})
    add_link_options("SHELL:${X}")
endforeach()

ADD_SUBDIRECTORY(lib)
ADD_SUBDIRECTORY(generic)
IF(RISCV_NN)
    ADD_SUBDIRECTORY(riscv_nn)
ENDIF()
