SET(AUTO_VECTORIZE_FLAGS "-fvectorize -fslp-vectorize")
IF(RISCV_VEXT)
    IF(RISCV_VLEN)
        IF(RISCV_VLEN GREATER_EQUAL 128)
            SET(AUTO_VECTORIZE_FLAGS "${AUTO_VECTORIZE_FLAGS} \
                -mllvm \
                -mllvm -scalable-vectorization=preferred \
            ")
                # TODO: expose to feature
                # --riscv-v-vector-bits-min=${RISCV_VLEN} \
                # --riscv-v-vector-bits-max=${RISCV_VLEN} \
        ENDIF()
    ENDIF()
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
# TODO: interesting
# -mllvm -force-vector-width=2 -mllvm -force-vector-interleave=1 \
# controll unroll?

IF(RISCV_AUTO_VECTORIZE_VERBOSE)
    SET(AUTO_VECTORIZE_FLAGS "${AUTO_VECTORIZE_FLAGS} \
        -Rpass=loop-vectorize -Rpass-missed=loop-vectorize -Rpass-analysis=loop-vectorize \
        -Rpass=slp-vectorize -Rpass-missed=slp-vectorize -Rpass-analysis=slp-vectorize \
    ")
ENDIF()
SET(FEATURE_EXTRA_C_FLAGS "${FEATURE_EXTRA_C_FLAGS} ${AUTO_VECTORIZE_FLAGS}")
SET(FEATURE_EXTRA_CXX_FLAGS "${FEATURE_EXTRA_CXX_FLAGS} ${AUTO_VECTORIZE_FLAGS}")
