#ifndef RVV_BENCH_INSTRUCTIONS_SCALAR_CONFIG_H
#define RVV_BENCH_INSTRUCTIONS_SCALAR_CONFIG_H

#define WARMUP 1000
#define UNROLL 64
#define LOOP 512
#define RUNS 4
// #define RUNS 1
// #define RUNS 1  // TODO:expose

// MLonMCU specific
#if defined(MLONMCU_TARGET_CV32E40P)
#define PRINTF_FLOAT_FIX
#endif

#if defined(MLONMCU_TARGET_VICUNA)
#define SKIP_FENCEI
#endif

#if defined(MLONMCU_TARGET_VICUNA2)
#define SKIP_FENCEI
#endif

#endif  // RVV_BENCH_INSTRUCTIONS_SCALAR_CONFIG_H
