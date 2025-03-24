#include <stddef.h>

int mlonmcu_init() {
  return 0;
}
int mlonmcu_deinit() {
  return 0;
}

unsigned int basic_hash(unsigned int op1, unsigned int op2) {
  unsigned int hash = 7;
  for (unsigned int i = 0; i < 32; i++) {
    hash = hash*31 + ((op1 >> i) & 1);
    hash = hash*31 + ((op2 >> i) & 1);
  }
  return hash;
}

#define SIZE 100

volatile unsigned const int X[SIZE];
unsigned const int Y[SIZE];
unsigned int Z[SIZE];

int mlonmcu_run() {
  for (size_t i = 0; i < SIZE; i++) {
      Z[i] = basic_hash(X[i], Y[i]);
  }
  return 0;
}

int mlonmcu_check() {
  return 0;
}
