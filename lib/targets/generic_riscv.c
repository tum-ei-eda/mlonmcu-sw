#include <stdio.h>
#include <stdint.h>
#include "riscv_time.h"
#include "riscv_utils.h"

/* How many cycles (rdcycle) per second (OVPsim and Spike). */
#define RDCYCLE_PER_SECOND 100000000UL

static uint64_t start_cycles = 0;

uint64_t target_cycles() { return rdcycle64(); }
uint64_t target_instructions() { return rdinstret64(); }

void target_init() {
  // enable_fext();
#ifdef USE_VEXT
  // enable_vext();
#endif
  // start_cycles = rdcycle64();
}

void target_deinit() {
  // uint64_t stop_cycles = rdcycle64();
  // uint64_t diff_cycles = stop_cycles - start_cycles;
  // // float diff_ms = 0;  // unimplemented (see RDCYCLE_PER_SECOND)
  // printf("Total Cycles: %llu\n", diff_cycles);
}
