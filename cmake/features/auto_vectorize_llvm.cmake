# IF(NOT RISCV_VEXT)
#     MESSAGE(FATAL_ERROR "RISCV_AUTO_VECTORIZE requires RISCV_VEXT")
# ENDIF()
# IF(RISCV_RVV_VLEN)
#     SET(VLEN ${RISCV_RVV_VLEN})
# ELSE()
#     SET(VLEN "?")
# ENDIF()
#  SET(CMAKE_CXX_FLAGS_RELEASE
#      "${CMAKE_CXX_FLAGS_RELEASE} \
#      -mllvm \
#      --riscv-v-vector-bits-min=${VLEN} \
#  "
#  )
#  SET(CMAKE_C_FLAGS_RELEASE
#      "${CMAKE_C_FLAGS_RELEASE} \
#      -mllvm \
#      --riscv-v-vector-bits-min=${VLEN} \
#  "
#  )
SET(AUTO_VECTORIZE_FLAGS "-fvectorize -fslp-vectorize")
IF(RISCV_VEXT)
    IF(RISCV_VLEN)
        # IF(RISCV_VLEN GREATER_EQUAL 128)
            SET(AUTO_VECTORIZE_FLAGS "${AUTO_VECTORIZE_FLAGS} \
                -mllvm \
                -scalable-vectorization=preferred \
            ")
                # TODO: expose to feature
                # --riscv-v-vector-bits-min=${RISCV_VLEN} \
                # --riscv-v-vector-bits-max=${RISCV_VLEN} \
        # ENDIF()
    ENDIF()
ENDIF()
IF(RISCV_AUTO_VECTORIZE_FORCE_VECTOR_WIDTH)
    SET(AUTO_VECTORIZE_FLAGS "${AUTO_VECTORIZE_FLAGS} \
        -mllvm --force-vector-width=${RISCV_AUTO_VECTORIZE_FORCE_VECTOR_WIDTH} \
    ")
ENDIF()
IF(RISCV_AUTO_VECTORIZE_FORCE_VECTOR_INTERLEAVE)
    SET(AUTO_VECTORIZE_FLAGS "${AUTO_VECTORIZE_FLAGS} \
        -mllvm --force-vector-interleave=${RISCV_AUTO_VECTORIZE_FORCE_INTERLEAVE_COUNT} \
    ")
ENDIF()
IF(DEFINED RISCV_AUTO_VECTORIZE_LOOP)
    IF(NOT RISCV_AUTO_VECTORIZE_LOOP)
        SET(AUTO_VECTORIZE_FLAGS "${AUTO_VECTORIZE_FLAGS} \
            -fno-vectorize \
        ")
    ENDIF()
ENDIF()
IF(DEFINED RISCV_AUTO_VECTORIZE_SLP)
    IF(NOT RISCV_AUTO_VECTORIZE_SLP)
        SET(AUTO_VECTORIZE_FLAGS "${AUTO_VECTORIZE_FLAGS} \
            -fno-slp-vectorize \
        ")
    ENDIF()
ENDIF()

IF(RISCV_AUTO_VECTORIZE_VERBOSE)
    SET(AUTO_VECTORIZE_FLAGS "${AUTO_VECTORIZE_FLAGS} \
        -Rpass=loop-vectorize -Rpass-missed=loop-vectorize -Rpass-analysis=loop-vectorize \
        -Rpass=slp-vectorize -Rpass-missed=slp-vectorize -Rpass-analysis=slp-vectorize \
    ")
ENDIF()
SET(FEATURE_EXTRA_C_FLAGS "${FEATURE_EXTRA_C_FLAGS} ${AUTO_VECTORIZE_FLAGS}")
SET(FEATURE_EXTRA_CXX_FLAGS "${FEATURE_EXTRA_CXX_FLAGS} ${AUTO_VECTORIZE_FLAGS}")
