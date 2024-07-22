#ifndef LIB_TARGETS_TARGET_H
#define LIB_TARGETS_TARGET_H

#include <stdint.h>
#include <stdio.h>
#include <stdarg.h>

#ifdef MLONMCU_TARGET_HOST_X86
#define HAS_CYCLES 1
#define HAS_INSTRUCTIONS 1
#define HAS_TIME 1
#else
#define HAS_CYCLES 1
#define HAS_INSTRUCTIONS 1
// #define HAS_TIME 1
#endif  // MLONMCU_TARGET_HOST_X86

uint64_t target_cycles();
uint64_t target_instructions();
uint64_t target_time();

__attribute__((weak)) void target_init() {}
__attribute__((weak)) void target_deinit() {}
#ifdef MLONMCU_TARGET_ARA
#include "printf.h"
#endif  // MLONMCU_TARGET_ARA
#define target_printf printf
// __attribute__((weak)) void target_printf(const char* format, ...) {
//     va_list argptr;
//     va_start(argptr, format);
//     vprintf(format, argptr);
//     va_end(argptr);
// }

#endif  // LIB_TARGETS_TARGET_H
