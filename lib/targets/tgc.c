#include <stdio.h>
#include <stdint.h>
#include "riscv_time.h"
#include "riscv_utils.h"

/* How many cycles (rdcycle) per second (OVPsim and Spike). */
#define RDCYCLE_PER_SECOND 100000000UL

// uint64_t target_cycles() { return rdcycle64(); } // always returns 0!
uint64_t target_cycles() { return rdinstret64(); }
uint64_t target_instructions() { return rdinstret64(); }
// float target_time() { return target_cycles() / (float)RDCYCLE_PER_SECOND; }

void init_target() {}
void deinit_target() {}
