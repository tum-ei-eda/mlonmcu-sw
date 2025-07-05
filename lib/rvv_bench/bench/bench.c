// #include <stdio.h>
// #include "printing.h"

int rvv_bench_main();

int mlonmcu_init() {
  return 0;
}
int mlonmcu_deinit() {
  return 0;
}
int mlonmcu_run() {
  return rvv_bench_main();
}
int mlonmcu_check() {
  return 0;
}
