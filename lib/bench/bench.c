#include "bench.h"

void start_bench(size_t index) {
#ifdef CYCLES
    BENCH_TYPE(CYCLES) cycles = BENCH_FUNC(CYCLES)();
#endif
#ifdef INSTRUCTIONS
    BENCH_TYPE(INSTRUCTIONS) instructions = BENCH_FUNC(INSTRUCTIONS)();
#endif
#ifdef TIME
    BENCH_TYPE(TIME) time = BENCH_FUNC(TIME)();
#endif
#ifdef CYCLES
    BENCH_DATA(CYCLES)[index] = cycles;
#endif
#ifdef INSTRUCTIONS
    BENCH_DATA(INSTRUCTIONS)[index] = instructions;
#endif
#ifdef TIME
    BENCH_DATA(TIME)[index] = time;
#endif
}

void stop_bench(size_t index) {
#ifdef CYCLES
    BENCH_TYPE(CYCLES) cycles = BENCH_FUNC(CYCLES)();
#endif
#ifdef INSTRUCTIONS
    BENCH_TYPE(INSTRUCTIONS) instructions = BENCH_FUNC(INSTRUCTIONS)();
#endif
#ifdef TIME
    BENCH_TYPE(TIME) time = BENCH_FUNC(TIME)();
#endif
    // TODO: check for overflow
#ifdef CYCLES
    BENCH_DATA(CYCLES)[index] = cycles - BENCH_DATA(CYCLES)[index];
#endif
#ifdef INSTRUCTIONS
    BENCH_DATA(INSTRUCTIONS)[index] = instructions - BENCH_DATA(INSTRUCTIONS)[index];
#endif
#ifdef TIME
    BENCH_DATA(TIME)[index] = time - BENCH_DATA(TIME)[index];
#endif
}

void print_bench(size_t index) {
    PRINT_BENCH_ALL
}
