SET(AUTO_VECTORIZE_FLAGS "-ftree-vectorize")
IF(RISCV_VEXT)
    IF(RISCV_VLEN)
        IF(RISCV_VLEN GREATER_EQUAL 128)
            SET(AUTO_VECTORIZE_FLAGS "${AUTO_VECTORIZE_FLAGS} -mriscv-vector-bits=${RISCV_VLEN}")
        ENDIF()
    ENDIF()
ENDIF()
IF(DEFINED RISCV_AUTO_VECTORIZE_LOOP)
    IF(NOT RISCV_AUTO_VECTORIZE_LOOP)
        SET(AUTO_VECTORIZE_FLAGS "${AUTO_VECTORIZE_FLAGS} \
            -fno-tree-loop-vectorize \
        ")
    ENDIF()
ENDIF()
IF(DEFINED RISCV_AUTO_VECTORIZE_SLP)
    IF(NOT RISCV_AUTO_VECTORIZE_SLP)
        SET(AUTO_VECTORIZE_FLAGS "${AUTO_VECTORIZE_FLAGS} \
            -fno-tree-slp-vectorize \
        ")
    ENDIF()
ENDIF()
# Also interesting:
# -mriscv-vector-lmul=<lmul>  Set the vf using lmul in auto-vectorization
    # -fsimd-cost-model=[unlimited|dynamic|cheap|very-cheap] Specifies the vectorization cost model for code marked with a simd directive

IF(RISCV_AUTO_VECTORIZE_VERBOSE)
    SET(AUTO_VECTORIZE_FLAGS "${AUTO_VECTORIZE_FLAGS} \
        -fopt-info-vec \
        -fopt-info-vec-missed \
    ")
ENDIF()
SET(FEATURE_EXTRA_C_FLAGS "${FEATURE_EXTRA_C_FLAGS} ${AUTO_VECTORIZE_FLAGS}")
SET(FEATURE_EXTRA_CXX_FLAGS "${FEATURE_EXTRA_CXX_FLAGS} ${AUTO_VECTORIZE_FLAGS}")
