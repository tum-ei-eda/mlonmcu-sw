#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
// #include <math.h>

#include "exit.h"

#include "dsp/basic_math_functions.h"


#ifndef SIZE
#define SIZE 16
#endif
#ifndef NUMBER
#define NUMBER 10
#endif
#ifndef BATCH
#define BATCH 1
#endif

#define MAX_SIZE 16
static const q31_t v0[MAX_SIZE] = {27.609375, 43.40625, 48.46875, -31.09375, -12.421875, 28.5, -14.6015625, -18.640625, 43.125, -18.28125, 44.34375, -35.15625, -40.375, -17.203125, -10.6953125, 13.34375};
static q31_t v1[SIZE * NUMBER];

#if (SIZE > MAX_SIZE)
#error "SIZE > MAX_SIZE not allowed"
#endif

int mlonmcu_init() {
  return 0;
}

volatile int result = 0;
int correct = 0;

int mlonmcu_deinit() {
  return 0;
}

int mlonmcu_run() {

  for (size_t n = 0; n < NUMBER; n++) {
    for (size_t i = 0; i < SIZE; i += BATCH) {
      arm_abs_q31(&v0[i], &v1[n*SIZE+i], BATCH);
    }
  }

  return 0;
}

int mlonmcu_check() {
  char correct = 1;
  if (!correct) {
    return EXIT_MLIF_MISSMATCH;
  }

  return 0;
}
