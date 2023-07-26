#ifndef TARGETLIB_TARGET_H
#define TARGETLIB_TARGET_H

#include <stdint.h>

#define HAS_CYCLES 1
#define HAS_INSTRUCTIONS 1
// #define HAS_TIME 1

#if HAS_CYCLES
uint64_t target_cycles();
#else
uint64_t target_cycles() { return 0; }
#endif  // HAS_CYCLES
#if HAS_INSTRUCTIONS
uint64_t target_instructions();
#else
uint64_t target_instructions() { return 0; }
#endif  // HAS_INSTRUCTIONS
#if HAS_TIME
float target_time();
#else
float target_time() { return 0.0; }
#endif  // HAS_TIME

__attribute__((weak)) void target_init() {}
__attribute__((weak)) void target_deinit() {}

#endif  // TARGETLIB_TARGET_H
