#include "support.h"
#include <stdio.h>

void
initialise_board ()
{
}

void __attribute__ ((noinline)) __attribute__ ((externally_visible))
start_trigger ()
{
}

void __attribute__ ((noinline)) __attribute__ ((externally_visible))
stop_trigger ()
{
}

int mlonmcu_init() {
  initialise_board();
  initialise_benchmark();
  warm_caches(WARMUP_HEAT);
}

volatile int result;
int correct;

int mlonmcu_deinit() {
  /* bmarks that use arrays will check a global array rather than int result */
  correct = verify_benchmark(result);
  printf("correct=%d\n", correct);

  return (!correct);
}

int mlonmcu_run() {
  // int i;

  start_trigger();
  result = benchmark();
  stop_trigger();
}
