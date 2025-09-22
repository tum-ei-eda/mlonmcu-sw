PROJECT(crypto_bench)

SET(CRYPTO_BENCH_BENCHMARK
    ""
    CACHE STRING "Specify which benchmark to run."
)
# SET_PROPERTY(CACHE TACLEBENCH_BENCHMARK PROPERTY STRINGS TODO)

SET(CRYPTO_BENCH_VERBOSE
    OFF
    CACHE BOOL "Enable verbose printf statements (HQC only)."
)

IF(NOT CRYPTO_BENCH_BENCHMARK)
    MESSAGE(FATAL_ERROR "Undefined: CRYPTO_BENCH_BENCHMARK")
ENDIF()

SET(MCELIECE_DIR ${CMAKE_CURRENT_LIST_DIR}/mceliece348864)

# TODO: only if riscv!
SET(COMMON_BENCH_SOURCES riscv_profiling.c)
set(BENCH_DEFS
    "PSEUDO_RNG"
)
set(FORCE_BENCH_DEFS
    "-DCRYPTO_NAMESPACE(x)=x"
    "-D_CRYPTO_NAMESPACE(x)=_##x"
)

set(ENCRYPT_SOURCES
    ${MCELIECE_DIR}/encrypt.c
)

set(DECRYPT_SOURCES
    ${MCELIECE_DIR}/decrypt.c
    ${MCELIECE_DIR}/fft.c
    ${MCELIECE_DIR}/fft_tr.c
    ${MCELIECE_DIR}/benes.c
    ${MCELIECE_DIR}/vec.c
    ${MCELIECE_DIR}/bm.c
    ${MCELIECE_DIR}/gf.c
)

set(KEYPAIR_SOURCES
    ${MCELIECE_DIR}/decrypt.c
    ${MCELIECE_DIR}/fft.c
    ${MCELIECE_DIR}/fft_tr.c
    ${MCELIECE_DIR}/benes.c
    ${MCELIECE_DIR}/vec.c
    ${MCELIECE_DIR}/bm.c
    ${MCELIECE_DIR}/gf.c
    ${MCELIECE_DIR}/operations.c
    ${MCELIECE_DIR}/controlbits.c
    ${MCELIECE_DIR}/sk_gen.c
    ${MCELIECE_DIR}/pk_gen.c
    ${MCELIECE_DIR}/fips202.c
    ${MCELIECE_DIR}/randombytes.c
)

IF(${CRYPTO_BENCH_BENCHMARK} STREQUAL "mceliece348864_encrypt")
    SET(BENCH_SOURCES mceliece_encrypt.c ${ENCRYPT_SOURCES})
ELSEIF(${CRYPTO_BENCH_BENCHMARK} STREQUAL "mceliece348864_encrypt_rvv")
    SET(BENCH_SOURCES mceliece_encrypt.c ${ENCRYPT_SOURCES} ${MCELIECE_DIR}/syndrome_rvv.c)
    LIST(APPEND BENCH_DEFS "-DRISCV")
ELSEIF(${CRYPTO_BENCH_BENCHMARK} STREQUAL "mceliece348864_decrypt")
    SET(BENCH_SOURCES mceliece_decrypt.c ${DECRYPT_SOURCES})
ELSEIF(${CRYPTO_BENCH_BENCHMARK} STREQUAL "mceliece348864_decrypt_rvv")
    SET(BENCH_SOURCES mceliece_decrypt.c ${DECRYPT_SOURCES})
    LIST(APPEND BENCH_DEFS "-DRISCV")
ELSEIF(${CRYPTO_BENCH_BENCHMARK} STREQUAL "mceliece348864_keypair")
    SET(BENCH_SOURCES mceliece_keypair.c ${KEYPAIR_SOURCES})
ELSEIF(${CRYPTO_BENCH_BENCHMARK} STREQUAL "mceliece348864_keypair_rvv")
    SET(BENCH_SOURCES mceliece_keypair.c ${KEYPAIR_SOURCES})
    LIST(APPEND BENCH_DEFS "-DRISCV")
ELSEIF(${CRYPTO_BENCH_BENCHMARK} MATCHES "hqc-.*")
    SET(HQC_BASE /work/git/colabs/tuw/parker/HQC-Round4/Additional_Implementation)  # TODO: expose
    SET(HQC_DIR ${HQC_BASE}/${CRYPTO_BENCH_BENCHMARK})
    SET(HQC_SOURCES
        ${HQC_DIR}/lib/fips202/fips202.c
        # ${HQC_DIR}/src/main_hqc.c
        main_hqc.c
        ${HQC_DIR}/src/vector.c
        ${HQC_DIR}/src/reed_muller.c
        ${HQC_DIR}/src/reed_solomon.c
        ${HQC_DIR}/src/fft.c
        ${HQC_DIR}/src/gf.c
        ${HQC_DIR}/src/gf2x.c
        ${HQC_DIR}/src/code.c
        ${HQC_DIR}/src/parsing.c
        ${HQC_DIR}/src/hqc.c
        ${HQC_DIR}/src/kem.c
        ${HQC_DIR}/src/shake_ds.c
        ${HQC_DIR}/src/shake_prng.c
    )
    IF(${CRYPTO_BENCH_VERBOSE})
        SET(BENCH_DEFS VERBOSE)
    ENDIF()
    SET(BENCH_SOURCES ${HQC_SOURCES})
    SET(BENCH_INCLUDES
        ${HQC_DIR}/lib/fips202/
        ${HQC_DIR}/src/
    )
    LIST(APPEND BENCH_DEFS "-DRISCV")
ELSE()
    MESSAGE(FATAL_ERROR "Unknown program: ${CRYPTO_BENCH_BENCHMARK}")
ENDIF()

# TODO: subdirs!
COMMON_ADD_LIBRARY(${PROJECT_NAME} STATIC ${COMMON_BENCH_SOURCES} ${BENCH_SOURCES})
TARGET_INCLUDE_DIRECTORIES(${PROJECT_NAME} PUBLIC . ${MCELIECE_DIR} ${MCELIECE_DIR}/subroutines ${BENCH_INCLUDES})
TARGET_LINK_LIBRARIES(${PROJECT_NAME} PRIVATE support)
TARGET_COMPILE_DEFINITIONS(${PROJECT_NAME} PRIVATE ${BENCH_DEFS})
TARGET_COMPILE_OPTIONS(${PROJECT_NAME} PRIVATE ${FORCE_BENCH_DEFS})

IF(${GLOBAL_ISEL})
target_compile_options(${PROJECT_NAME} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:C>:-mllvm -global-isel=1>")
target_compile_options(${PROJECT_NAME} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:CXX>:-mllvm -global-isel=1>")
SET(GLOBAL_ISEL_ABORT 2)
target_compile_options(${PROJECT_NAME} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:C>:-mllvm -global-isel-abort=${GLOBAL_ISEL_ABORT}>")
target_compile_options(${PROJECT_NAME} PRIVATE "SHELL:$<$<COMPILE_LANGUAGE:CXX>:-mllvm -global-isel-abort=${GLOBAL_ISEL_ABORT}>")
ENDIF()
