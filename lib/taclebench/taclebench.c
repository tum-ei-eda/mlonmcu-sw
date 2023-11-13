// order of includes is relevant here since taclebench may conflictbwith stdio.h
#include "exit.h"
#include "taclebench_wrapper.h"

int mlonmcu_init() {
  return 0;
}
int mlonmcu_deinit() {
  return 0;
}

int ret = 0;

int mlonmcu_run() {
  ret = taclebench_main();
  return 0;
}
int mlonmcu_check() {
  if (ret < 0) {
      return EXIT_MLIF_MISSMATCH;
  }
  return 0;
}
