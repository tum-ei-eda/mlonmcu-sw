#include <stddef.h>

int mlonmcu_init() {
  return 0;
}
int mlonmcu_deinit() {
  return 0;
}

unsigned int load_filter(unsigned int op1, unsigned int op2) {
    unsigned int filter = op1;
    // for (unsigned int i = 0; i < 32; i++) {
        if ((op2 & (1 << 31)) != 0) filter = op2;
    // }
    return filter;
}

#define SIZE 32000

unsigned const int X[SIZE];
unsigned const int Y[SIZE];
unsigned int Z[SIZE];

int mlonmcu_run() {
  for (size_t i = 0; i < SIZE; i++) {
      Z[i] = load_filter(X[i], Y[i]);
  }
  return 0;
}

int mlonmcu_check() {
  return 0;
}
