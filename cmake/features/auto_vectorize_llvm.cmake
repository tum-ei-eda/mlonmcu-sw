IF(NOT RISCV_VEXT)
    # MESSAGE(FATAL_ERROR "RISCV_AUTO_VECTORIZE requires RISCV_VEXT")
ELSE()
    IF(RISCV_VLEN)
        SET(VLEN ${RISCV_VLEN})
    ELSE()
        SET(VLEN "?")
    ENDIF()
    SET(CMAKE_CXX_FLAGS_RELEASE
        "${CMAKE_CXX_FLAGS_RELEASE} \
        -mllvm \
        --riscv-v-vector-bits-min=${VLEN} \
    "
    )
    SET(CMAKE_C_FLAGS_RELEASE
        "${CMAKE_C_FLAGS_RELEASE} \
        -mllvm \
        --riscv-v-vector-bits-min=${VLEN} \
    "
    )
ENDIF()

# TODO: interesting
# -mllvm -force-vector-width=2 -mllvm -force-vector-interleave=1 \
# controll unroll?

IF(RISCV_AUTO_VECTORIZE_VERBOSE)
    SET(CMAKE_CXX_FLAGS_RELEASE
        "${CMAKE_CXX_FLAGS_RELEASE} \
        -Rpass=loop-vectorize -Rpass-missed=loop-vectorize -Rpass-analysis=loop-vectorize \
        -Rpass=slp-vectorize -Rpass-missed=slp-vectorize -Rpass-analysis=slp-vectorize \
    "
    )
    SET(CMAKE_C_FLAGS_RELEASE
        "${CMAKE_C_FLAGS_RELEASE} \
        -Rpass=loop-vectorize -Rpass-missed=loop-vectorize -Rpass-analysis=loop-vectorize \
        -Rpass=slp-vectorize -Rpass-missed=slp-vectorize -Rpass-analysis=slp-vectorize \
    "
    )

ENDIF()
