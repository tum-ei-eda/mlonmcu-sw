#ifndef LIB_TARGETS_TARGET_H
#define LIB_TARGETS_TARGET_H

#include <stdint.h>

#define HAS_CYCLES 1
#define HAS_INSTRUCTIONS 1
// #define HAS_TIME 1

uint64_t target_cycles();
uint64_t target_instructions();
float target_time();

__attribute__((weak)) void target_init() {}
__attribute__((weak)) void target_deinit() {}

#endif  // LIB_TARGETS_TARGET_H
