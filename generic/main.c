#include "mlonmcu.h"
#include "target.h"
#include "bench.h"
#include <stdio.h>

// void init_target();
// void deinit_target();

int main() {
  // pre
  target_init();
  printf("Program start.\n");

  // main
  start_bench(TOTAL);
  start_bench(INIT);
  mlonmcu_init();
  stop_bench(INIT);
  start_bench(RUN);
  mlonmcu_run();
  stop_bench(RUN);
  // TODO: time check
  mlonmcu_check();
  // start_bench(DEINIT);
  mlonmcu_deinit();
  // stop_bench(DEINIT);
  stop_bench(TOTAL);

  // post
  print_bench(INIT);
  print_bench(RUN);
  // print_bench(DEINIT);
  print_bench(TOTAL);
  printf("Program finish.\n");
  target_deinit();

  // TODO: exit code from  mlonmcu_init and mlonmcu_bench
  return 0;
}
