#include <stdint.h>
#include <stddef.h>
#include <inttypes.h>
#include <stdio.h>

#include <target.h>

#define MAX_NUM_BENCH 3

#define INIT 0
#define RUN 1
#define TOTAL 2

#if HAS_CYCLES && HAS_INSTRUCTIONS && HAS_TIME
#define MAX_METRICS_IDX 2
#elif HAS_CYCLES && HAS_INSTRUCTIONS
#define CYCLES 0
#define INSTRUCTIONS 1
#define MAX_METRICS_IDX 1
#elif HAS_CYCLES && HAS_TIME
#define CYCLES 0
#define TIME 1
#define MAX_METRICS_IDX 1
#elif HAS_INSTRUCTIONS && HAS_TIME
#define INSTRUCTIONS 0
#define TIME 1
#define MAX_METRICS_IDX 1
#elif HAS_CYCLES
#define CYCLES 0
#define MAX_METRICS_IDX 0
#elif HAS_INSTRUCTIONS
#define INSTRUCTIONS 0
#define MAX_METRICS_IDX 0
#elif HAS_TIME
#define TIME 0
#define MAX_METRICS_IDX 0
#endif

#define BENCH_NAME_0 "Setup"
#define BENCH_NAME_1 "Run"
#define BENCH_NAME_2 "Total"

static char* bench_names[MAX_NUM_BENCH] = {BENCH_NAME_0, BENCH_NAME_1, BENCH_NAME_2};

#define BENCH_METRIC_0 "Cycles"
#define BENCH_METRIC_1 "Instructions"
#define BENCH_METRIC_2 "Runtime"

#define BENCH_TYPE_0 uint64_t
#define BENCH_TYPE_1 uint64_t
#define BENCH_TYPE_2 float

#define BENCH_FMT_0 PRIu64
#define BENCH_FMT_1 PRIu64
#define BENCH_FMT_2 "f"

#define BENCH_FUNC_0 target_cycles
#define BENCH_FUNC_1 target_instructions
#define BENCH_FUNC_2 target_time

#define BENCH_NAME2(index) BENCH_NAME_ ## index
#define BENCH_NAME(index) BENCH_NAME2(index)
#define BENCH_METRIC2(index) BENCH_METRIC_ ## index
#define BENCH_METRIC(index) BENCH_METRIC2(index)
#define BENCH_TYPE2(index) BENCH_TYPE_ ## index
#define BENCH_TYPE(index) BENCH_TYPE2(index)
#define BENCH_FMT2(index) BENCH_FMT_ ## index
#define BENCH_FMT(index) BENCH_FMT2(index)
#define BENCH_FUNC2(index) BENCH_FUNC_ ## index
#define BENCH_FUNC(index) BENCH_FUNC2(index)

// #define BENCH_DATA(index) "static " ## BENCH_TYPE(index) ## " temp_" ## index ## " [" ## MAX_NUM_ ## "] = {0};"

// BENCH_DATA(INIT)
// BENCH_DATA(RUN)
// BENCH_DATA(TOTAL)

#define BENCH_DATA2(metric) temp_ ## metric
#define BENCH_DATA(metric) BENCH_DATA2(metric)
#define BENCH_DATA_DECL(metric) static BENCH_TYPE(metric) BENCH_DATA(metric)[MAX_NUM_BENCH] = {0};

#ifdef CYCLES
BENCH_DATA_DECL(CYCLES)
#endif
#ifdef INSTRUCTIONS
BENCH_DATA_DECL(INSTRUCTIONS)
#endif
#ifdef TIME
BENCH_DATA_DECL(TIME)
#endif

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

// #define PRINT_BENCH(index, metric) printf("%s " BENCH_METRIC(metric) ": %" BENCH_FMT(metric) "\n", bench_names[index], BENCH_DATA(metric)[index]);
// #define PRINT_BENCH_1(index) \
//   PRINT_BENCH(index, 1)
// #define PRINT_BENCH_2(index) \
//   PRINT_BENCH_1 \
//   PRINT_BENCH(index, 2)
// #define PRINT_BENCH_3_(index) \
//   PRINT_BENCH_2 \
//   PRINT_BENCH(index, 3)
// #define PRINT_BENCH_3(index) PRINT_BENCH_3_(index)
// #define PRINT_BENCH_TO2(index, to) PRINT_BENCH_ ## to ## (index)
// #define PRINT_BENCH_TO(index, to) PRINT_BENCH_TO2(index, to)
// #define PRINT_BENCH_ALL(index) PRINT_BENCH_TO(index, MAX_NUM_METRICS)
#define PRINT_BENCH(metric) printf("# %s " BENCH_METRIC(metric) ": %" BENCH_FMT(metric) "\n", bench_names[index], BENCH_DATA(metric)[index]);
#define PRINT_BENCH_0 \
  PRINT_BENCH(0)
#define PRINT_BENCH_1 \
  PRINT_BENCH_0 \
  PRINT_BENCH(1)
#define PRINT_BENCH_2 \
  PRINT_BENCH_1 \
  PRINT_BENCH(2)
#define PRINT_BENCH_3 \
  PRINT_BENCH_2
// #define PRINT_BENCH_3 PRINT_BENCH_3_
#define PRINT_BENCH_TO2(to) PRINT_BENCH_ ## to
#define PRINT_BENCH_TO(to) PRINT_BENCH_TO2(to)
#define PRINT_BENCH_ALL PRINT_BENCH_TO(MAX_METRICS_IDX)

void print_bench(size_t index) {
    PRINT_BENCH_ALL
}
