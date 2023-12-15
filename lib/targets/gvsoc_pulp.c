#include <stdio.h>

#define CSR_PULP_PCMR 0xCC1
#define CSR_PULP_PCER 0xCC0
#define CSR_PULP_PCCR0 0x780

#define csr_write(csr, val)         \
({                \
  unsigned long __v = (unsigned long)(val);   \
  __asm__ ("csrw " #csr ", %0" \
            : : "rK" (__v)      \
            : "memory");      \
})

#define csr_read(csr)           \
({                \
  register unsigned long __v;       \
  __asm__ ("csrr %0, " #csr  \
            : "=r" (__v) :      \
            : "memory");      \
  __v;              \
  })


static uint32_t start_cycles = 0;
static uint32_t start_instructions = 0;

void init_target() {
  csr_write(0xCC0, 0b11);
}

void start_timer() {
  start_cycles = csr_read(0x780);
  start_instructions = csr_read(0x781);
  // printf("Start Cycles: %ld\n", start_cycles);
  // printf("Start Instructions: %ld\n", start_instructions);
}

void stop_timer() {
  uint32_t stop_cycles = csr_read(0x780);
  uint32_t stop_instructions = csr_read(0x781);
  // WARNING: 32bit ony, overflows after 4294967295 cycles (42s at 100MHz)
  uint32_t diff_cycles = stop_cycles - start_cycles;
  uint32_t diff_instructions = stop_instructions - start_instructions;
  printf("Total Cycles: %ld\n", diff_cycles);
  printf("Total Instructions: %ld\n", diff_instructions);
}

void deinit_target() {}
