MESSAGE(STATUS "MU")
IF(MURISCVNN)
    MESSAGE(STATUS "MU2")
    IF(NOT MURISCVNN_DIR)
        MESSAGE(FATAL_ERROR "Missing value: MURISCVNN_DIR")
    ENDIF()

    IF("${MURISCVNN_VEXT}" STREQUAL "AUTO")
        IF(NOT RISCV_VEXT)
            SET(USE_VEXT OFF)
        ELSE()
            SET(USE_VEXT ON)
        ENDIF()
    ELSE()
        SET(USE_VEXT ${MURISCVNN_VEXT})
    ENDIF()

    IF("${MURISCVNN_PEXT}" STREQUAL "AUTO")
        IF(NOT RISCV_PEXT)
            SET(USE_PEXT OFF)
        ELSE()
            SET(USE_PEXT ON)
        ENDIF()
    ELSE()
        SET(USE_PEXT ${MURISCVNN_PEXT})
    ENDIF()


    # IF(RISCV_AUTO_VECTORIZE)
    #     SET(USE_AUTO_VECTORIZE ${RISCV_AUTO_VECTORIZE})
    #     SET(USE_AUTO_VECTORIZE_VLEN ${RISCV_VLEN})
    # ELSE()
    #     SET(USE_AUTO_VECTORIZE OFF)
    #     SET(USE_AUTO_VECTORIZE_VLEN 1024)
    #
    # ENDIF()


    # IF(NOT MURISCVNN_TOOLCHAIN)
    #     SET(MURISCVVN_TOOLCHAIN GCC)
    #     # SET(MURISCVVN_TOOLCHAIN NONE)
    # ENDIF()
    SET(MURISCVNN_LIB muriscvnn)
    SET(SIMULATOR ETISS)  # TODO: allow None
    if(USE_VEXT AND USE_PEXT)
      message(FATAL_ERROR "V/P-Extension can not be enabled simultaneously.")
    elseif(USE_VEXT)
      add_definitions(-DUSE_VEXT)
    elseif(USE_PEXT)
      add_definitions(-DUSE_PEXT)
    endif()
    ADD_SUBDIRECTORY(${MURISCVNN_DIR}/Source muriscvnn)
    target_include_directories(${MURISCVNN_LIB} PUBLIC
        ${MURISCVNN_DIR}/Include
        ${MURISCVNN_DIR}/Include/CMSIS/NN/Include
    )
    target_link_libraries(${MURISCVNN_LIB} PUBLIC m)
    foreach(X IN ITEMS ${FEATURE_EXTRA_C_FLAGS})
    	target_compile_options(${MURISCVNN_LIB} PUBLIC "SHELL:$<$<COMPILE_LANGUAGE:C>:${X}>")
    endforeach()

    # SET(MURISCVNN_INCLUDE_DIRS ${MURISCVNN_DIR}/Include ${MURISCVNN_DIR}/Include/CMSIS/NN/Include)
    SET(MURISCVNN_INCLUDE_DIRS ${MURISCVNN_DIR}/Include ${MURISCVNN_DIR}/Include/CMSIS/NN/Include ${MURISCVNN_DIR}/Include/CMSIS/NN)

    # # TODO: propagarting all toolchain specific vars does not scale well
    # SET(BUILD_FLAGS "")
    # IF(RISCV_ARCH)
    #     SET(BUILD_FLAGS "${BUILD_FLAGS} -march=${RISCV_ARCH}")
    # ENDIF()
    # IF(RISCV_ABI)
    #     SET(BUILD_FLAGS "${BUILD_FLAGS} -mabi=${RISCV_ABI}")
    # ENDIF()
    #
    # # TODO: define array with all values which need to be passed for toolchain file!
    #
    # SET(ARGS "")
    #
    # FOREACH(X ${TC_VARS};CMAKE_TRY_COMPILE_TARGET_TYPE)
    #     SET(ARGS "${ARGS} -D${X}=\"${${X}}\"")
    # ENDFOREACH()
    #
    # separate_arguments(ARGS UNIX_COMMAND "${ARGS}")
    #
    # INCLUDE(ExternalProject)
    # EXTERNALPROJECT_ADD(
    #     muriscvnn
    #     PREFIX muriscvnn
    #     SOURCE_DIR ${MURISCVNN_DIR}
    #     CMAKE_ARGS -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    #                -DCMAKE_C_FLAGS:STRING=${BUILD_FLAGS}
    #                -DCMAKE_CXX_FLAGS:STRING=${BUILD_FLAGS}
    #                -DUSE_VEXT=${USE_VEXT}
    #                -DUSE_PEXT=${USE_PEXT}
    #                -DTOOLCHAIN=${MURISCVNN_TOOLCHAIN}
    #                -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
    #                -DENABLE_UNIT_TESTS=OFF
    #                -DARM_CPU=${ARM_CPU}
    #                -DARM_FLOAT_ABI=${ARM_FLOAT_ABI}
    #                -DARM_FPU=${ARM_FPU}
    #                ${ARGS}
    #     BUILD_COMMAND "${CMAKE_COMMAND}" --build . -j ${SUBPROJECT_THREADS}
    #     INSTALL_COMMAND ""
    # )
    # # -DAUTO_VECTORIZE=${USE_AUTO_VECTORIZE}
    # # -DAUTO_VECTORIZE_VLEN=${USE_AUTO_VECTORIZE_VLEN}
    #
    # EXTERNALPROJECT_GET_PROPERTY(muriscvnn BINARY_DIR)
    SET(MURISCVNN_OUT ${CMAKE_BINARY_DIR}/muriscvnn/libmuriscvnn.a)

    # TFLite integration
    IF(TFLM_OPTIMIZED_KERNEL_LIB)
        LIST(APPEND TFLM_OPTIMIZED_KERNEL_LIB ${MURISCVNN_OUT})
    ELSE()
        SET(TFLM_OPTIMIZED_KERNEL_LIB ${MURISCVNN_OUT})
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
        LIST(APPEND TVM_EXTRA_LIBS ${MURISCVNN_OUT})
    ELSE()
        SET(TVM_EXTRA_LIBS ${MURISCVNN_OUT})
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

    foreach(X IN ITEMS ${EXTRA_C_FLAGS} ${FEATURE_EXTRA_C_FLAGS})
        MESSAGE(STATUS "X=${X}")
        target_compile_options(${MURISCVNN_LIB} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:C>:${X}>")
    endforeach()
    foreach(X IN ITEMS ${EXTRA_CXX_FLAGS} ${FEATURE_EXTRA_CXX_FLAGS})
        target_compile_options(${MURISCVNN_LIB} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:CXX>:${X}>")
    endforeach()
    foreach(X IN ITEMS ${EXTRA_ASM_FLAGS} ${FEATURE_EXTRA_ASM_FLAGS})
        target_compile_options(${MURISCVNN_LIB} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:ASM>:${X}>")
    endforeach()
    foreach(X IN ITEMS ${EXTRA_LD_FLAGS} ${FEATURE_EXTRA_LD_FLAGS})
        target_link_options(${MURISCVNN_LIB} PRIVATE "SHELL:${X}")
    endforeach()
ENDIF()
