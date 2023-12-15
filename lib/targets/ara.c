#include <stdio.h>
#include <stdint.h>
#include "riscv_time.h"
#include "riscv_utils.h"
#include "printf.h"

/* How many cycles (rdcycle) per second (OVPsim and Spike). */
#define RDCYCLE_PER_SECOND 100000000UL

static uint64_t start_cycles = 0;

uint64_t target_cycles() { return rdcycle64(); }
// inline int64_t get_cycle_count() {
//   int64_t cycle_count;
//   // The fence is needed to be sure that Ara is idle, and it is not performing
//   // the last vector stores when we read mcycle with stop_timer()
//   asm volatile("fence; csrr %[cycle_count], cycle"
//                : [cycle_count] "=r"(cycle_count));
//   return cycle_count;
// };
uint64_t target_instructions() { return rdinstret64(); }
// float target_time() { return target_cycles() / (float)RDCYCLE_PER_SECOND; }

void target_init() {
  // enable_fext();
  // enable_vext();
#ifdef USE_VEXT
#endif
}

void target_deinit() {}
// void target_printf(const char* format, ...) {
//     va_list argptr;
//     va_start(argptr, format);
//     printf(format, argptr);
//     va_end(argptr);
// }
// typedef void (*out_fct_type)(char character, void *buffer, size_t idx,
//                              size_t maxlen);
// static inline void _out_char(char character, void *buffer, size_t idx,
//                              size_t maxlen);
// static int _vsnprintf(out_fct_type out, char *buffer, const size_t maxlen,
//                       const char *format, va_list va);
// void target_printf_(const char *format, ...) {
//   va_list va;
//   va_start(va, format);
//   char buffer[1];
//   _vsnprintf(_out_char, buffer, (size_t)-1, format, va);
//   va_end(va);
// }
#define target_printf printf_
