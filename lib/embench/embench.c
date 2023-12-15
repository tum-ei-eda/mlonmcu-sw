#include "support.h"
#include "exit.h"
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
  return 0;
}

volatile int result = 0;
int correct = 0;

int mlonmcu_deinit() {
  return 0;
}

int mlonmcu_run() {
  // int i;

  start_trigger();
  result = benchmark();
  stop_trigger();
  return 0;
}
int mlonmcu_check() {
  /* bmarks that use arrays will check a global array rather than int result */
  correct = verify_benchmark(result);
  if (!correct) {
      return EXIT_MLIF_MISSMATCH;
  }

  return 0;
}
