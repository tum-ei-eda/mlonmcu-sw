#include <stdio.h>
#include <stdint.h>
#include "riscv_time.h"
#include "riscv_utils.h"

/* How many cycles (rdcycle) per second (OVPsim and Spike). */
#define RDCYCLE_PER_SECOND 100000000UL

static uint64_t start_cycles = 0;

uint64_t target_cycles() { return rdcycle64(); }
uint64_t target_instructions() { return rdinstret64(); }
// float target_time() { return target_cycles() / (float)RDCYCLE_PER_SECOND; }

#define csr_write(csr, val)         \
({                \
  unsigned long __v = (unsigned long)(val);   \
  __asm__ ("csrw " #csr ", %0" \
            : : "rK" (__v)      \
            : "memory");      \
})
void target_init() {
  // csr_write(800, 0b1111);
  // volatile unsigned int wevent = (unsigned int) -1;
#ifdef HPM3
  volatile unsigned int wevent3 =  (unsigned int) 0b00000000000000000000000000000100; // ld_stall
  __asm__ volatile("csrw mhpmevent3, %0" : : "r"(wevent3));
#endif  // HPM3
#ifdef HPM4
  volatile unsigned int wevent4 =  (unsigned int) 0b00000000000000000000000000001000; // jmp_stall
  __asm__ volatile("csrw mhpmevent4, %0" : : "r"(wevent4));
#endif  // HPM4
  // volatile unsigned int wevent3 =  (unsigned int) 0b00000000000000000000000000000001; // cycles
  // volatile unsigned int wevent4 =  (unsigned int) 0b00000000000000000000000000000010; // instrs
  // volatile unsigned int wevent7 =  (unsigned int) 0b00000000000000000000000000010000; // imiss
  // volatile unsigned int wevent8 =  (unsigned int) 0b00000000000000000000000000100000; // ld
  // volatile unsigned int wevent9 =  (unsigned int) 0b00000000000000000000000001000000; // st
  // volatile unsigned int wevent10 = (unsigned int) 0b00000000000000000000000010000000; // jump
  // volatile unsigned int wevent11 = (unsigned int) 0b00000000000000000000000100000000; // branch
  // volatile unsigned int wevent12 = (unsigned int) 0b00000000000000000000001000000000; // branch_taken
  // volatile unsigned int wevent13 = (unsigned int) 0b00000000000000000000010000000000; // comp_instr
  // volatile unsigned int wevent14 = (unsigned int) 0b00000000000000000000100000000000; // pipe_stall
  // volatile unsigned int wevent15 = (unsigned int) 0b00000000000000000001000000000000; // APU_TYPE
  // volatile unsigned int wevent16 = (unsigned int) 0b00000000000000000010000000000000; // APU_CONT
  // volatile unsigned int wevent17 = (unsigned int) 0b00000000000000000100000000000000; // APU_DEP
  // volatile unsigned int wevent18 = (unsigned int) 0b00000000000000001000000000000000; // APU_WB
  // __asm__ volatile("csrw mhpmevent4, %0" : : "r"(wevent4));
  // __asm__ volatile("csrw mhpmevent5, %0" : : "r"(wevent5));
  // __asm__ volatile("csrw mhpmevent6, %0" : : "r"(wevent6));
  // __asm__ volatile("csrw mhpmevent7, %0" : : "r"(wevent7));
  // __asm__ volatile("csrw mhpmevent8, %0" : : "r"(wevent8));
  // __asm__ volatile("csrw mhpmevent9, %0" : : "r"(wevent9));
  // __asm__ volatile("csrw mhpmevent10, %0" : : "r"(wevent10));
  // __asm__ volatile("csrw mhpmevent11, %0" : : "r"(wevent11));
  // __asm__ volatile("csrw mhpmevent12, %0" : : "r"(wevent12));
  // __asm__ volatile("csrw mhpmevent13, %0" : : "r"(wevent13));
  // __asm__ volatile("csrw mhpmevent14, %0" : : "r"(wevent14));
  // __asm__ volatile("csrw mhpmevent15, %0" : : "r"(wevent15));
  // __asm__ volatile("csrw mhpmevent16, %0" : : "r"(wevent16));
  // __asm__ volatile("csrw mhpmevent17, %0" : : "r"(wevent17));
  // __asm__ volatile("csrw mhpmevent18, %0" : : "r"(wevent18));
}

void target_deinit() {
  // enable_fext();

#if defined(HPM_COUNTERS) && HPM_COUNTERS > 0
    volatile unsigned int mhpmcounter_rval[HPM_COUNTERS];
#ifdef HPM3
  __asm__ volatile("csrr %0, 0xB03" : "=r"(mhpmcounter_rval[3]));
#endif  // HPM3
#ifdef HPM4
  __asm__ volatile("csrr %0, 0xB04" : "=r"(mhpmcounter_rval[4]));
#endif  // HPM4
    for (int i=3; i<32; i++) {
      mlonmcu_printf("HPM[%d]=%d\n", i, mhpmevent_rval[i]);
    }
#endif  // HPM_COUNTERS
    // volatile unsigned int mcycle_rval;
    // volatile unsigned int minstret_rval;
    // volatile unsigned int mcountinhibit_rval;
    // volatile unsigned int mhpmcounter_rval[32];
    // volatile unsigned int mhpmevent_rval[32];
    // volatile unsigned int mhartid_rval;
    // volatile unsigned int sum;
    // volatile unsigned int count;
    // volatile unsigned int event;
    // volatile unsigned int err_cnt;
    // __asm__ volatile(".option rvc");

    // err_cnt = 0;
    // count = 0;
    // event = 0;

    // printf("\n\nPerformance Counters Basic Test\n");

    // __asm__ volatile("csrr %0, 0xB00" : "=r"(mcycle_rval));
    // __asm__ volatile("csrr %0, 0xB02" : "=r"(minstret_rval));


    // __asm__ volatile("csrr %0, 0x320" : "=r"(mcountinhibit_rval));


    // __asm__ volatile("csrr %0, 0xB03" : "=r"(mhpmcounter_rval[3]));
    // __asm__ volatile("csrr %0, 0xB04" : "=r"(mhpmcounter_rval[4]));
    // __asm__ volatile("csrr %0, 0xB05" : "=r"(mhpmcounter_rval[5]));
    // __asm__ volatile("csrr %0, 0xB06" : "=r"(mhpmcounter_rval[6]));
    // __asm__ volatile("csrr %0, 0xB07" : "=r"(mhpmcounter_rval[7]));
    // __asm__ volatile("csrr %0, 0xB08" : "=r"(mhpmcounter_rval[8]));
    // __asm__ volatile("csrr %0, 0xB09" : "=r"(mhpmcounter_rval[9]));
    // __asm__ volatile("csrr %0, 0xB0A" : "=r"(mhpmcounter_rval[10]));
    // __asm__ volatile("csrr %0, 0xB0B" : "=r"(mhpmcounter_rval[11]));
    // __asm__ volatile("csrr %0, 0xB0C" : "=r"(mhpmcounter_rval[12]));
    // __asm__ volatile("csrr %0, 0xB0D" : "=r"(mhpmcounter_rval[13]));
    // __asm__ volatile("csrr %0, 0xB0E" : "=r"(mhpmcounter_rval[14]));
    // __asm__ volatile("csrr %0, 0xB0F" : "=r"(mhpmcounter_rval[15]));
    // __asm__ volatile("csrr %0, 0xB10" : "=r"(mhpmcounter_rval[16]));
    // __asm__ volatile("csrr %0, 0xB11" : "=r"(mhpmcounter_rval[17]));
    // __asm__ volatile("csrr %0, 0xB12" : "=r"(mhpmcounter_rval[18]));
    // __asm__ volatile("csrr %0, 0xB13" : "=r"(mhpmcounter_rval[19]));
    // __asm__ volatile("csrr %0, 0xB14" : "=r"(mhpmcounter_rval[20]));
    // __asm__ volatile("csrr %0, 0xB15" : "=r"(mhpmcounter_rval[21]));
    // __asm__ volatile("csrr %0, 0xB16" : "=r"(mhpmcounter_rval[22]));
    // __asm__ volatile("csrr %0, 0xB17" : "=r"(mhpmcounter_rval[23]));
    // __asm__ volatile("csrr %0, 0xB18" : "=r"(mhpmcounter_rval[24]));
    // __asm__ volatile("csrr %0, 0xB19" : "=r"(mhpmcounter_rval[25]));
    // __asm__ volatile("csrr %0, 0xB1A" : "=r"(mhpmcounter_rval[26]));
    // __asm__ volatile("csrr %0, 0xB1B" : "=r"(mhpmcounter_rval[27]));
    // __asm__ volatile("csrr %0, 0xB1C" : "=r"(mhpmcounter_rval[28]));
    // __asm__ volatile("csrr %0, 0xB1D" : "=r"(mhpmcounter_rval[29]));
    // __asm__ volatile("csrr %0, 0xB1E" : "=r"(mhpmcounter_rval[30]));
    // __asm__ volatile("csrr %0, 0xB1F" : "=r"(mhpmcounter_rval[31]));


    // __asm__ volatile("csrr %0, 0x323" : "=r"(mhpmevent_rval[3]));
    // __asm__ volatile("csrr %0, 0x324" : "=r"(mhpmevent_rval[4]));
    // __asm__ volatile("csrr %0, 0x325" : "=r"(mhpmevent_rval[5]));
    // __asm__ volatile("csrr %0, 0x326" : "=r"(mhpmevent_rval[6]));
    // __asm__ volatile("csrr %0, 0x327" : "=r"(mhpmevent_rval[7]));
    // __asm__ volatile("csrr %0, 0x328" : "=r"(mhpmevent_rval[8]));
    // __asm__ volatile("csrr %0, 0x329" : "=r"(mhpmevent_rval[9]));
    // __asm__ volatile("csrr %0, 0x32A" : "=r"(mhpmevent_rval[10]));
    // __asm__ volatile("csrr %0, 0x32B" : "=r"(mhpmevent_rval[11]));
    // __asm__ volatile("csrr %0, 0x32C" : "=r"(mhpmevent_rval[12]));
    // __asm__ volatile("csrr %0, 0x32D" : "=r"(mhpmevent_rval[13]));
    // __asm__ volatile("csrr %0, 0x32E" : "=r"(mhpmevent_rval[14]));
    // __asm__ volatile("csrr %0, 0x32F" : "=r"(mhpmevent_rval[15]));
    // __asm__ volatile("csrr %0, 0x330" : "=r"(mhpmevent_rval[16]));
    // __asm__ volatile("csrr %0, 0x331" : "=r"(mhpmevent_rval[17]));
    // __asm__ volatile("csrr %0, 0x332" : "=r"(mhpmevent_rval[18]));
    // __asm__ volatile("csrr %0, 0x333" : "=r"(mhpmevent_rval[19]));
    // __asm__ volatile("csrr %0, 0x334" : "=r"(mhpmevent_rval[20]));
    // __asm__ volatile("csrr %0, 0x335" : "=r"(mhpmevent_rval[21]));
    // __asm__ volatile("csrr %0, 0x336" : "=r"(mhpmevent_rval[22]));
    // __asm__ volatile("csrr %0, 0x337" : "=r"(mhpmevent_rval[23]));
    // __asm__ volatile("csrr %0, 0x338" : "=r"(mhpmevent_rval[24]));
    // __asm__ volatile("csrr %0, 0x339" : "=r"(mhpmevent_rval[25]));
    // __asm__ volatile("csrr %0, 0x33A" : "=r"(mhpmevent_rval[26]));
    // __asm__ volatile("csrr %0, 0x33B" : "=r"(mhpmevent_rval[27]));
    // __asm__ volatile("csrr %0, 0x33C" : "=r"(mhpmevent_rval[28]));
    // __asm__ volatile("csrr %0, 0x33D" : "=r"(mhpmevent_rval[29]));
    // __asm__ volatile("csrr %0, 0x33E" : "=r"(mhpmevent_rval[30]));
    // __asm__ volatile("csrr %0, 0x33F" : "=r"(mhpmevent_rval[31]));

    // for (int i=3; i<32; i++) {
    //   printf("mhpmevent_rval[%d]=%d\n", i, mhpmevent_rval[i]);
    //   sum += mhpmevent_rval[i];
    // }
    // if (sum) {
    //   printf("ERROR: CSR MHPMEVENT[3..31] not 0x0!\n\n");
    //   ++err_cnt;
    // }

    // for (int i=3; i<32; i++) {
    //   printf("mhpmcounter_rval[%d]=%d\n", i, mhpmcounter_rval[i]);
    //   sum += mhpmcounter_rval[i];
    // }
    // printf("mcycle_rval=%x\n", mcycle_rval);
    // printf("minstret_rval=%x\n", minstret_rval);
    // printf("mcountinhibit_rval=%x\n", mcountinhibit_rval);
}
