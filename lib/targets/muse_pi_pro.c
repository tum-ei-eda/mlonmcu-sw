#include <stdio.h>
#include <stdint.h>

#define USE_LINUX_TIME
#ifdef USE_LINUX_TIME
#include "linux_time.h"
#else
#include "riscv_time.h"
#endif

// #include "riscv_utils.h"

#ifndef RDTIME_PER_SECOND
#define RDTIME_PER_SECOND 24000000UL  // 24 MHz timebase freq
#endif

#ifdef USE_LINUX_TIME
uint64_t target_time() { return linux_time_us(); }
#else
uint64_t target_time() { return rdtime64() / (float)RDTIME_PER_SECOND * 1e6; }
#endif

void target_init() {
  // enable_fext();
#ifdef USE_VEXT
  // enable_vext();
#endif
}

void target_deinit() {}
