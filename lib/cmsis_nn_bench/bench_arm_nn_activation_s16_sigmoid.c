#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
// #include <math.h>

#include "exit.h"

#include "arm_nnfunctions.h"
#include "arm_nnsupportfunctions.h"


#ifndef SIZE
#define SIZE 16
#endif
#ifndef NUMBER
#define NUMBER 10
#endif
#ifndef BATCH
#define BATCH 1
#endif

#define CELL_SCALE_POWER -12

#define MAX_SIZE 16
static const int16_t input_buf[MAX_SIZE] = {27.609375, 43.40625, 48.46875, -31.09375, -12.421875, 28.5, -14.6015625, -18.640625, 43.125, -18.28125, 44.34375, -35.15625, -40.375, -17.203125, -10.6953125, 13.34375};
static int16_t output_buf[SIZE * NUMBER];

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

  const int32_t size = SIZE * SIZE;
  const int32_t left_shift = CELL_SCALE_POWER + 12;

  for (size_t n = 0; n < NUMBER; n++) {
    for (size_t i = 0; i < SIZE; i += BATCH) {
      arm_nn_activation_s16(&input_buf[i], &output_buf[n*SIZE+i], BATCH, left_shift, ARM_SIGMOID);
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
