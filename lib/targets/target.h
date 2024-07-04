#ifndef LIB_TARGETS_TARGET_H
#define LIB_TARGETS_TARGET_H

#include <stdint.h>
#include <stdio.h>
#include <stdarg.h>

#define HAS_CYCLES 1
#define HAS_INSTRUCTIONS 1
// #define HAS_TIME 1

uint64_t target_cycles();
uint64_t target_instructions();
float target_time();

__attribute__((weak)) void target_init() {}
__attribute__((weak)) void target_deinit() {}
#if defined(MLONMCU_TARGET_ARA)
#include "printf.h"
#define target_printf printf
#elif defined(MLONMCU_TARGET_VICUNA)
#include "uart.h"
#define target_printf uart_printf
#else
#define target_printf printf
#endif
// __attribute__((weak)) void target_printf(const char* format, ...) {
//     va_list argptr;
//     va_start(argptr, format);
//     vprintf(format, argptr);
//     va_end(argptr);
// }

#endif  // LIB_TARGETS_TARGET_H
