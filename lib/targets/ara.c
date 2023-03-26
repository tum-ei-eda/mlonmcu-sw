#include "printf.h"
// #include <stdio.h>
#include<stdint.h>
#include "encoding.h"

uint64_t rdcycle64(){
#if __riscv_xlen == 32
    uint32_t cycles;
    uint32_t cyclesh1;
    uint32_t cyclesh2;
    do
    {
        cyclesh1 = rdcycleh();
        cycles = rdcycle();
        cyclesh2 = rdcycleh();
    } while (cyclesh1 != cyclesh2);
  return (((uint64_t)cyclesh1) << 32) | cycles;
#else
  return rdcycle();
#endif
}

uint64_t rdinstret64(){
#if __riscv_xlen == 32
    uint32_t instrets;
    uint32_t instretsh1;
    uint32_t instretsh2;
    do
    {
        instretsh1 = rdinstreth();
        instrets = rdinstret();
        instretsh2 = rdinstreth();
    } while (instretsh1 != instretsh2);
  return (((uint64_t)instretsh1) << 32) | instrets;
#else
  return rdinstret();
#endif
}

static uint64_t start_cycles = 0;
static uint64_t start_instructions = 0;

void init_target() {
  // enable_fext();
#ifdef USE_VEXT
  // enable_vext();
#endif
  start_cycles = rdcycle64();
  start_instructions = rdinstret64();
}

void deinit_target() {
  uint64_t stop_cycles = rdcycle64();
  uint64_t diff_cycles = stop_cycles - start_cycles;
  uint64_t stop_instructions = rdinstret64();
  uint64_t diff_instructions = stop_instructions - start_instructions;
  float diff_ms = 0;  // unimplemented (see RDCYCLE_PER_SECOND)
  printf("Total Cycles: %ld\n", diff_cycles);
  printf("Total Instructions: %ld\n", diff_instructions);
}




